# shellcheck disable=SC2148

for cmd in alpyki songchro; do
  if [[ ${commands[$cmd]} ]]; then
    _evalcache $cmd completion --shell zsh
  fi
done
