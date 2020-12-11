#!/usr/bin/env bash

cd "$(dirname "$0")/.."
. script/functions

if ! command -v go; then
  abort "Go must be installed"
fi

go get -u github.com/codejanovic/gordon
go get -u github.com/go-delve/delve/cmd/dlv
go get -u github.com/gogo/protobuf/protoc-gen-gogofast
go get -u golang.org/x/lint/golint
go get -u golang.org/x/tools/cmd/godoc
go get -u golang.org/x/tools/cmd/goimports
go get -u rsc.io/goversion
