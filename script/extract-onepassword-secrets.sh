#!/usr/bin/env bash

set -e

cd "$(dirname "$0")/.."

mkdir -p ~/.ssh
mkdir -p ~/.gnupg

onepassword_login() {
  if ! command -v op >/dev/null
  then
    echo "Install op first!" >&2
    exit 1
  fi

  # shellcheck disable=SC2154
  if [ -z "$OP_SESSION_my" ]
  then
    echo "Logging into 1Password..."
    eval "$(op signin my.1password.com acourtneybrown@gmail.com)"
  fi
}

onepassword_get() {
  if [ -f "$HOME/$2" ]
  then
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
onepassword_get rzsa6e4uhfflbgt6m24w37sdsa .gnupg/acourtneybrown@github.com.private.gpg-key

if ! [ -f "$HOME/.secrets" ]
then
  echo "Extracting secrets..."
  if ! command -v jq >/dev/null
  then
    echo "Install jq first!" >&2
    exit 1
  fi
  onepassword_login

  touch "${HOME}/.secrets"
  chmod 600 "${HOME}/.secrets"

  octofactory_username=$(op get item iaamiupwtfa6rpqcelvcagq2au | jq -r '.details.fields[] | select(.designation=="username").value')
  octofactory_password=$(op get item iaamiupwtfa6rpqcelvcagq2au | jq -r '.details.fields[] | select(.designation=="password").value')
  octofactory_url=$(op get item iaamiupwtfa6rpqcelvcagq2au | jq -r '.details.sections[0].fields[0].v')

  cat >> "$HOME/.secrets" <<EOF
octofactory_username=${octofactory_username}
octofactory_password=${octofactory_password}
octofactory_url=${octofactory_url}
EOF
fi

echo "Storing SSH keys in keychain..."
ssh-add -K

echo "Setting up GPG..."
if ! command -v gpg >/dev/null
then
    echo "Install GPG first!" >&2
    exit 1
fi

chmod 700 ~/.gnupg
gpg --import ~/.gnupg/acourtneybrown@gmail.com.private.gpg-key

gpg --import ~/.gnupg/acourtneybrown@github.com.private.gpg-key
