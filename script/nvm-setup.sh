#!/usr/bin/env bash

if [[ -d ~/.nvm ]]; then
  git -C ~/.nvm pull origin
else
  git clone https://github.com/nvm-sh/nvm.git ~/.nvm
fi
