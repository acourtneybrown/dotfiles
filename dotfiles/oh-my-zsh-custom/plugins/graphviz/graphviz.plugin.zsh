# shellcheck disable=SC2148

# shellcheck disable=SC2154
if [[ ${commands[dot]} ]]; then
  # dotall will run the dot command over all .gv files in a directory & generate image.
  # by default, it will output png images, but an optional argument can specify a different type
  function dotall() {
    local type
    type=png
    if [[ ${#} -eq 1 ]]; then
      type="${1}"
    fi

    find . -maxdepth 1 -name '*.gv' | while read -r file; do
      dot -T"${type}" "${file}" >"${file}.${type}"
    done
  }
fi
