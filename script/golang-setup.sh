#!/usr/bin/env bash

set -e

cd "$(dirname "${0}")/.."

# shellcheck disable=SC1091
. script/functions

if ! command -v go; then
  abort "Go must be installed"
fi

go install github.com/codejanovic/gordon
go install github.com/go-delve/delve/cmd/dlv
go install github.com/gogo/protobuf/protoc-gen-gogofast
go install golang.org/x/lint/golint
go install golang.org/x/tools/cmd/godoc
go install golang.org/x/tools/cmd/goimports
go install rsc.io/goversion
