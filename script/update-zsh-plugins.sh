#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

git subtree pull --prefix dotfiles/oh-my-zsh-custom/plugins/evalcache https://github.com/mroth/evalcache.git master --squash
