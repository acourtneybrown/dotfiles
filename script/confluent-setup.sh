#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

ensure_brewfile_installed Brewfile.confluent

pyenv install --skip-existing "$(pyenv latest --known 3.8)"
pipx_install "$(pyenv latest 3.8)" confluent-release-tools

pyenv install --skip-existing "$(pyenv latest --known 3.9)"
pipx_install "$(pyenv latest 3.9)" confluent-ci-tools

pyenv install --skip-existing "$(pyenv latest --known 3.11)"
pipx_install "$(pyenv latest 3.11)" ansible-hostmanager bump2version gimme-aws-creds gql tox
