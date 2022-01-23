#!/usr/bin/env bash

# see https://discussions.apple.com/thread/3298804?answerId=21199204022#21199204022

set -e

cd "$(dirname "${0}")/.."

if ! grep 'nfs.client.mount.options = intr,locallocks,nfc' /etc/nfs.conf; then
  echo 'nfs.client.mount.options = intr,locallocks,nfc' | sudo tee -a /etc/nfs.conf
fi
