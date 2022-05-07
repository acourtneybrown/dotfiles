#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

ensure_brewfile_installed Brewfile.confluent

ensure_autopip_installed

# Install app that contains pint command and optionally keep it updated daily so you don't have to
app install release-tools --update daily
app install tox --update daily
app install confluent-ci-tools --update daily

pipx install gimme-aws-creds

if [[ -d ~/.cc-dotfiles ]]; then
  git -C ~/.cc-dotfiles pull origin
else
  git clone https://github.com/confluentinc/cc-dotfiles.git ~/.cc-dotfiles
fi
