#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

mkdir -p ~/.ssh
mkdir -p ~/.gnupg

eval "$(op signin)"

function onepassword_get() {
  if [ -f "${HOME}/${2}" ]; then
    echo "${2} already exists."
    return
  fi
  echo "Extracting ${2}..."
  op document get "${1}" --output "${HOME}/${2}"
  chmod 600 "${HOME}/${2}"
}

if ! [ -f "${HOME}/.secrets" ]; then
  echo "Extracting secrets..."
  ensure_command "jq"

  touch "${HOME}/.secrets"
  chmod 600 "${HOME}/.secrets"

  cat >>"${HOME}/.secrets" <<EOF
artifactory_host=$(op item get "JFrog Artifactory" --format json | jq '.urls[0].href')
artifactory_password=$(op item get "JFrog Artifactory" --fields "API Key")
artifactory_path=$(op item get "JFrog Artifactory" --fields "Root path")
artifactory_user=$(op item get "JFrog Artifactory" --fields username)
gh_cli_token=$(op item get "GitHub" --fields "gh cli token")
github_netrc_token=$(op item get "GitHub" --fields "Confluent netrc")
hub_cli_token=$(op item get "GitHub" --fields "hub cli token")
semaphore_api_token=$(op item get "Semaphore API Token" --fields password)
okta_default_device_token=$(op item get "Okta" --fields "gimme-aws-creds device_token")
EOF
fi

echo "Setting up GPG..."
ensure_command "gpg"

# shellcheck disable=SC2174
mkdir -p -m 700 ~/.gnupg
for key in acourtneybrown@gmail.com abrown@confluent.io; do
  onepassword_get "${key}.private.gpg-key" .gnupg/"${key}.private.gpg-key"

  if ! gpg --list-keys | grep -q "${key}"; then
    op item get "${key}.private.gpg-key passphrase" --fields password | gpg --batch --passphrase-fd 0 --import "${HOME}/.gnupg/${key}.private.gpg-key"
  else
    echo "key for ${key} already imported"
  fi
done
