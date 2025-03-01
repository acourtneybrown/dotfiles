# shellcheck disable=SC2148

if [[ ${commands[twilio]} ]]; then
  eval "$(twilio autocomplete:script zsh)"
fi
