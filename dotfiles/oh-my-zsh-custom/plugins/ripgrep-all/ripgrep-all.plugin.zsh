# shellcheck disable=SC2148

if [[ ${commands[rga]} && ${commands[fzf]} ]]; then

  # rga-fzf provides interactive integration between rga &
  # See https://github.com/phiresky/ripgrep-all#integration-with-fzf
  function rga-fzf() {
    RG_PREFIX="rga --files-with-matches"
    local file
    file="$(
      FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
        fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
        --phony -q "$1" \
        --bind "change:reload:$RG_PREFIX {q}" \
        --preview-window="70%:wrap"
    )" &&
      echo "opening $file" &&
      open "$file"
  }
fi
