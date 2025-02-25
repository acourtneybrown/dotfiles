# shellcheck disable=SC2148

if [[ ${commands[twilio]} ]]; then
  # TODO: fix autocomplete because of 1Password plugin
  eval "$(/usr/bin/env twilio autocomplete:script zsh)"
fi
