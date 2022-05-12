#!/usr/bin/env bash

if [[ -d ~/.pyenv ]]; then
  git -C ~/.pyenv pull origin
else
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
fi
