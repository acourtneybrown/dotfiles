#!/usr/bin/env bash
set -e
cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

ensure_autopip_installed

autopip install --update weekly python-kasa
