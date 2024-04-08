# shellcheck disable=SC2148

if [ -d ~/.iterm2-shell-integration ]; then
  for U in ~/.iterm2-shell-integration/utilities/*; do
    alias "$(basename $U)"=$U
  done
fi
