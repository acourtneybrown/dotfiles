#!/usr/bin/env bash

# Adapted from https://github.com/MikeMcQuaid/strap

# Setup Homebrew directory and permissions.
echo "Installing Homebrew:"
HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
[ -n "${HOMEBREW_PREFIX}" ] || HOMEBREW_PREFIX="/usr/local"
[ -d "${HOMEBREW_PREFIX}" ] || sudo mkdir -p "${HOMEBREW_PREFIX}"
if [ "${HOMEBREW_PREFIX}" = "/usr/local" ]; then
  sudo chown "root:wheel" "${HOMEBREW_PREFIX}" 2>/dev/null || true
fi
(
  cd "${HOMEBREW_PREFIX}"
  sudo mkdir -p Cellar Frameworks bin etc include lib opt sbin share var
  sudo chown -R "${USER}:admin" Cellar Frameworks bin etc include lib opt sbin share var
)

HOMEBREW_REPOSITORY="$(brew --repository 2>/dev/null || true)"
[ -n "${HOMEBREW_REPOSITORY}" ] || HOMEBREW_REPOSITORY="/usr/local/Homebrew"
[ -d "${HOMEBREW_REPOSITORY}" ] || sudo mkdir -p "${HOMEBREW_REPOSITORY}"
sudo chown -R "${USER}:admin" "${HOMEBREW_REPOSITORY}"

if [ ${HOMEBREW_PREFIX} != ${HOMEBREW_REPOSITORY} ]; then
  ln -sf "${HOMEBREW_REPOSITORY}/bin/brew" "${HOMEBREW_PREFIX}/bin/brew"
fi

# Download Homebrew.
export GIT_DIR="${HOMEBREW_REPOSITORY}/.git" GIT_WORK_TREE="${HOMEBREW_REPOSITORY}"
git init -q
git config remote.origin.url "https://github.com/Homebrew/brew"
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch -q --tags --force
git reset -q --hard origin/master
unset GIT_DIR GIT_WORK_TREE

# Update Homebrew.
export PATH="${HOMEBREW_PREFIX}/bin:${PATH}"
echo "Updating Homebrew:"
brew update
