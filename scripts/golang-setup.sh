#!/usr/bin/env bash

# Only run xcode-select when found (on MacOS)
[ $(which xcode-select) ] && xcode-select --install

go get -u github.com/go-delve/delve/cmd/dlv
go get -u rsc.io/goversion
go get -u github.com/codejanovic/gordon
