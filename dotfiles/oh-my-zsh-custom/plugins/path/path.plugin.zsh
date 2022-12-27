# shellcheck disable=SC2148

paths=("${HOME}/bin" "${HOME}/go/bin" /usr/local/bin /usr/local/sbin)

# ZSH "properly" handles the array (vs. bash)
# shellcheck disable=SC2128
for dir in ${paths}; do
  if [[ -d "${dir}" ]]; then
    # Actually *want* path to be split
    # shellcheck disable=2206
    path=("${dir}" ${path})
  fi
done

typeset -U path
export PATH
