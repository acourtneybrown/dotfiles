#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

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

onepassword_get "Adam's id_rsa SSH key" .ssh/id_rsa
onepassword_get "Synology root SSH key" .ssh/synology
onepassword_get "id_ed25519.confluent" .ssh/id_ed25519.confluent

if ! [ -f ~/.ssh/id_ed25519.confluent.pub ]; then
  echo "Retreiving public key for id_ed25519.confluent"
  ssh-keygen -y -f ~/.ssh/id_ed25519.confluent >~/.ssh/id_ed25519.confluent.pub
fi
ln -sf id_ed25519.confluent ~/.ssh/caas-abrown
ln -sf id_ed25519.confluent.pub ~/.ssh/caas-abrown.pub

onepassword_get "Adam's Personal GPG key" .gnupg/acourtneybrown@gmail.com.private.gpg-key
onepassword_get "Confluent GPG key" .gnupg/abrown@confluent.io.private.gpg-key

if ! [ -f "${HOME}/.secrets" ]; then
  echo "Extracting secrets..."
  if ! command -v jq >/dev/null; then
    echo "Install jq first!" >&2
    exit 1
  fi

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
okta_default_device_token=$(op item get "Okta" --fields "gimme-aws-creds default device_token")
okta_toolsterraform_device_token=$(op item get "Okta" --fields "gimme-aws-creds ToolsTerraform device_token")
semaphore_api_token=$(op item get "Semaphore API Token" --fields password)
EOF
fi

echo "Storing SSH keys in keychain..."
ssh-add -K

echo "Setting up GPG..."
if ! command -v gpg >/dev/null; then
  echo "Install GPG first!" >&2
  exit 1
fi

chmod 700 ~/.gnupg
gpg --import ~/.gnupg/acourtneybrown@gmail.com.private.gpg-key
gpg --import ~/.gnupg/abrown@confluent.io.private.gpg-key
