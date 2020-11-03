#!/usr/bin/env bash

set -e

cd "$(dirname "$0")/.."

mkdir -p ~/.ssh
mkdir -p ~/.gnupg

onepassword_login() {
  if ! command -v op > /dev/null; then
    echo "Install op first!" >&2
    exit 1
  fi

  # shellcheck disable=SC2154
  if [ -z "$OP_SESSION_my" ]; then
    echo "Logging into 1Password..."
    eval "$(op signin my.1password.com acourtneybrown@gmail.com)"
  fi
}

onepassword_get() {
  if [ -f "$HOME/$2" ]; then
    echo "$2 already exists."
    return
  fi
  echo "Extracting $2..."
  onepassword_login
  op get document "$1" > "$HOME/$2"
  chmod 600 "$HOME/$2"
}

# onepassword_get ... .ssh/id_ed25519
onepassword_get emqicp7w4jd4taxig5sb3qdumm .ssh/id_rsa
onepassword_get whmrixtghfedbmtajlrz4pwqdu .ssh/synology
onepassword_get vnxlg6na7fhrvnyhzo2pulh2ri .gnupg/acourtneybrown@gmail.com.private.gpg-key
onepassword_get pct2u52rzfg5jo5cbgfmbcjf5m .gnupg/abrown@confluent.io.private.gpg-key

if ! [ -f "$HOME/.secrets" ]; then
  echo "Extracting secrets..."
  if ! command -v jq > /dev/null; then
    echo "Install jq first!" >&2
    exit 1
  fi
  onepassword_login

  touch "${HOME}/.secrets"
  chmod 600 "${HOME}/.secrets"

  github_repo_token=$(op get item 5atqzjpi35bjjmesbyko52nerq - --fields "Repo (read) token")
  artifactory_host=$(op get item iyrzrhrvdzb3ri5eymhp3i5ob4 - --fields url)
  artifactory_path=$(op get item iyrzrhrvdzb3ri5eymhp3i5ob4 - --fields "Root path")
  artifactory_user=$(op get item iyrzrhrvdzb3ri5eymhp3i5ob4 - --fields username)
  artifactory_password=$(op get item iyrzrhrvdzb3ri5eymhp3i5ob4 - --fields "API Key")

  cat >> "$HOME/.secrets" << EOF
github_repo_token=${github_repo_token}
artifactory_host=${artifactory_host}
artifactory_path=${artifactory_path}
artifactory_user=${artifactory_user}
artifactory_password=${artifactory_password}
EOF
fi

echo "Storing SSH keys in keychain..."
ssh-add -K

echo "Setting up GPG..."
if ! command -v gpg > /dev/null; then
  echo "Install GPG first!" >&2
  exit 1
fi

chmod 700 ~/.gnupg
gpg --import ~/.gnupg/acourtneybrown@gmail.com.private.gpg-key
gpg --import ~/.gnupg/acourtneybrown@gmail.com.private.gpg-key
