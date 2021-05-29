#!/usr/bin/env bash

# On Raspberry Pi, ensure en_US.UTF-8 locale available & installed
# sudo perl -pi -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
# sudo locale-gen en_US.UTF-8
# sudo update-locale en_US.UTF-8

# TODO: make this work for non-Debian distro?
case $(lsb_release --id --short) in
Raspbian | Debian)
  sudo apt -q -y install ruby
  ;;
esac

# From https://docs.brew.sh/Homebrew-on-Linux#alternative-installation
if [ ! -d ~/.linuxbrew ]; then
  git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
  mkdir ~/.linuxbrew/bin
  ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
else
  git -C ~/.linuxbrew/Homebrew pull
fi
eval "$(~/.linuxbrew/bin/brew shellenv)"
