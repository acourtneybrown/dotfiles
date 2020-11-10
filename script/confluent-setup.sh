#!/usr/bin/env bash

cd "$(dirname "$0")/.."
. script/functions

ensure_brewfile_installed Brewfile.confluent

/usr/local/opt/python3/bin/pip3 install -U autopip

# Keep autopip updated automatically by installing itself
app install autopip==1.* --update monthly

# Install app that contains pint command and optionally keep it updated daily so you don't have to
app install release-tools --update daily
app install tox --update daily

if [[ -d ~/.cc-dotfiles ]]; then
  git -C ~/.cc-dotfiles pull origin
else
  git clone https://github.com/confluentinc/cc-dotfiles.git ~/.cc-dotfiles
fi
