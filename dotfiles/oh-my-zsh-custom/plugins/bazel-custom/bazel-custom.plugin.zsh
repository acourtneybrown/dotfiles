# shellcheck disable=SC2148

# shellcheck disable=SC1091
source "{{@@ _dotdrop_dotpath @@}}/../script/lib/docker.sh"

username_cb="op item get Docker --field username"
docker_pat_cb="op item get Docker --field 'Bazel PAT'"
docker::ensure_login index.docker.io "${username_cb}" "${docker_pat_cb}"
unset docker_username_cb docker_pat_cb

if [[ -f ${HOME}/.config/coursier/credentials.properties ]]; then
  export COURSIER_CREDENTIALS=${HOME}/.config/coursier/credentials.properties
fi

export GOPRIVATE="github.com/confluentinc/*"

# bazel_clean_cache deletes cache file older than the time specified (60d by default)
function bazel_clean_cache() {
  local OLDER_THAN=${1:-60d}
  find "${HOME}/.cache/bazel" -type f -atime "+${OLDER_THAN}" -delete
}

# bazel_deps outputs the dependency graph for a given Bazel target (default //...)
function bazel_deps() {
  local target
  target="${1-//...}"
  bazel query --notool_deps --noimplicit_deps "deps(${target})" --output graph
}

# show_bazel_deps opens an SVG of the bazel_deps output
function show_bazel_deps() {
  local svgfile
  svgfile="$(mktemp).svg" || return 1
  bazel_deps "${@}" | dot -Tsvg >"${svgfile}"
  open "${svgfile}"
}

# sri_hash produces the Subresource Integrity hash for a given file
# This value is needed for archive_override w/ Bzlmod
# For details, see https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity
function sri_hash() {
  if [[ ${#} -ne 2 ]]; then
    echo "Usage:"
    echo "${0} <filename> <hash algo>"
    return 1
  fi

  openssl dgst "-${2}" -binary <"${1}" | openssl base64 -A
}

# bazel_all run the given command over every resulting target for the given query
function bazel_all() {
  local command="${1}"
  shift
  bazel query "${@}" | xargs -n 1 bazel "${command}"
}

alias bazel-clean-cache=bazel_clean_cache
alias sri-hash=sri_hash
alias bazel-deps=bazel_deps
alias show-bazel-deps=show_bazel_deps
alias stbob='st "$(bazel info output_base)"'
alias bazel-all=bazel_all
