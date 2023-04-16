# shellcheck disable=SC2148

# paths in reverse order of the expectation
paths=(/usr/local/sbin /usr/local/bin "${HOME}/go/bin" "${HOME}/bin")

# ZSH "properly" handles the array (vs. bash)
# shellcheck disable=SC2128
for dir in ${paths}; do
  if [[ -d "${dir}" ]]; then
    # Actually *want* path to be split
    # shellcheck disable=2206
    path=("${dir}" ${path})
  fi
done
