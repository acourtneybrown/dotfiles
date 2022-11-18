#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

ensure_brewfile_installed Brewfile.confluent

pipx install confluent-ci-tools
pipx install confluent-release-tools
pipx install gimme-aws-creds
pipx install gql
pipx install tox
