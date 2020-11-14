#!/usr/bin/env bash

cd "$(dirname "$0")/.."
. script/functions

ensure_autopip_installed

autopip install --update weekly python-kasa
