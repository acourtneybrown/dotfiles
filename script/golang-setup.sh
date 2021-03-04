#!/usr/bin/env bash

cd "$(dirname "$0")/.."
. script/functions

if ! command -v go; then
  abort "Go must be installed"
fi

go install github.com/codejanovic/gordon@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/gogo/protobuf/protoc-gen-gogofast@latest
go install golang.org/x/lint/golint@latest
go install golang.org/x/tools/cmd/godoc@latest
go install golang.org/x/tools/cmd/goimports@latest
go install rsc.io/goversion@latest
