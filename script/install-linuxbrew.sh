#!/usr/bin/env bash

# On Raspberry Pi, ensure en_US.UTF-8 locale available & installed
if [ -f /etc/locale.gen ]; then
  sudo sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
  sudo locale-gen en_US.UTF-8
  sudo update-locale en_US.UTF-8
fi

# TODO: make this work for non-Debian distro?
case $(lsb_release --id --short) in
Raspbian | Debian)
  sudo apt -q -y install libssl-dev libreadline-dev
  ;;
esac

# Install and update rbenv and Ruby 2.6.3
if [ ! -d "${HOME}/.rbenv" ]; then
  git clone https://github.com/rbenv/rbenv.git "${HOME}/.rbenv"
fi
export PATH="${HOME}/.rbenv/bin:${PATH}"

if [ ! -d "${HOME}/.rbenv/plugins/ruby-build" ]; then
  mkdir -p "${HOME}/.rbenv/plugins"
  git clone https://github.com/rbenv/ruby-build.git "${HOME}/.rbenv/plugins/ruby-build"
fi

pushd "${HOME}/.rbenv" || exit
git pull
cd "${HOME}/.rbenv/plugins/ruby-build" || exit
git pull
popd || exit
rbenv install 2.6.3

# From https://docs.brew.sh/Homebrew-on-Linux#alternative-installation
if [ ! -d "${HOME}/.linuxbrew" ]; then
  git clone https://github.com/Homebrew/brew "${HOME}/.linuxbrew/Homebrew"
  mkdir "${HOME}/.linuxbrew/bin"
  ln -s "${HOME}/.linuxbrew/Homebrew/bin/brew" "${HOME}/.linuxbrew/bin"
else
  git -C "${HOME}/.linuxbrew/Homebrew" pull
fi
eval "$("${HOME}"/.linuxbrew/bin/brew shellenv)"
