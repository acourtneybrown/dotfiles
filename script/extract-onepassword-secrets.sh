#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

mkdir -p ~/.ssh
mkdir -p ~/.gnupg

function onepassword_login() {
  if ! command -v op >/dev/null; then
    echo "Install op first!" >&2
    exit 1
  fi

  # shellcheck disable=SC2154
  if [ -z "${OP_SESSION_my}" ]; then
    echo "Logging into 1Password..."
    eval "$(op signin my.1password.com acourtneybrown@gmail.com)"
  fi
}

function onepassword_get() {
  if [ -f "${HOME}/${2}" ]; then
    echo "${2} already exists."
    return
  fi
  echo "Extracting ${2}..."
  onepassword_login
  op get document "${1}" --output "${HOME}/${2}"
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
  onepassword_login

  touch "${HOME}/.secrets"
  chmod 600 "${HOME}/.secrets"

  artifactory_host=$(op get item "JFrog Artifactory" - --fields url)
  artifactory_password=$(op get item "JFrog Artifactory" - --fields "API Key")
  artifactory_path=$(op get item "JFrog Artifactory" - --fields "Root path")
  artifactory_user=$(op get item "JFrog Artifactory" - --fields username)
  gh_cli_token=$(op get item "GitHub" - --fields "gh cli token")
  github_netrc_token=$(op get item "GitHub" - --fields "Confluent netrc")
  okta_default_device_token=$(op get item "Okta" - --fields "gimme-aws-creds default device_token")
  okta_toolsterraform_device_token=$(op get item "Okta" - --fields "gimme-aws-creds ToolsTerraform device_token")

  cat >>"${HOME}/.secrets" <<EOF
artifactory_host=${artifactory_host}
artifactory_password=${artifactory_password}
artifactory_path=${artifactory_path}
artifactory_user=${artifactory_user}
gh_cli_token=${gh_cli_token}
github_netrc_token=${github_netrc_token}
okta_default_device_token=${okta_default_device_token}
okta_toolsterraform_device_token=${okta_toolsterraform_device_token}
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
