#!/usr/bin/env bash
set -e
cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

ensure_brewfile_installed Brewfile.confluent

enable_pyenv
pipx_install 3.8 confluent-release-tools
pipx_install 3.9 confluent-ci-tools
pipx_install 3.11 ansible-hostmanager bump2version gimme-aws-creds gql tox
