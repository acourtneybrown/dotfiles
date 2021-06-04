#!/usr/bin/env bash
# Encrypt a file to send it securely to another Hubber
#
# Use https://gpgtools.org/ for an easy to use decryption UI.
#
# Usage:
#   enc4hub <GitHub handle> /path/to/file
#
set -e

usage() {
  echo "Usage:"
  echo "$0 <GitHub handle> /path/to/file"
  exit 1
}

if [ ${#} -ne 2 ]; then
  usage
fi

recipient="${1}"
file="${2}"

# Import the public key of the recipient from GitHub
gpg --import <(curl --silent "https://github.com/${recipient}.gpg")

# Encrypt the file with the recipient's key and sign it with my own key
gpg --encrypt --sign --armor --trust-model always --recipient "${recipient}@github.com" "${file}"
