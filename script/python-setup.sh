#!/usr/bin/env bash
set -e
cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
source script/functions

pipx_install 3.11 python-kasa python-vipaccess
