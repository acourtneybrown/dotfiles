#!/usr/bin/env bash

cd "$(dirname "${0}")/.."
. script/functions

ensure_brewfile_installed Brewfile.confluent

ensure_autopip_install

# Install app that contains pint command and optionally keep it updated daily so you don't have to
app install release-tools --update daily
app install tox --update daily
app install confluent-ci-tools --update daily

if [[ -d ~/.cc-dotfiles ]]; then
  git -C ~/.cc-dotfiles pull origin
else
  git clone https://github.com/confluentinc/cc-dotfiles.git ~/.cc-dotfiles
fi
