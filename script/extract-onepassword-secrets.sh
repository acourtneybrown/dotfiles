#!/usr/bin/env bash

set -e
cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

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
