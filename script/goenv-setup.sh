#!/usr/bin/env bash

if [[ -d ~/.goenv ]]; then
  git -C ~/.goenv pull origin
else
  git clone https://github.com/syndbg/goenv.git ~/.goenv
fi
