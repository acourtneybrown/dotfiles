#!/usr/bin/env zsh
# shellcheck disable=SC1071

export OP_PLUGIN_ALIASES_SOURCED=1
twilio() {
    op plugin run -- twilio "$@"
}
gh() {
    op plugin run -- gh "$@"
}
glab() {
    op plugin run -- glab "$@"
}
gt() {
    op plugin run -- gt "$@"
}
