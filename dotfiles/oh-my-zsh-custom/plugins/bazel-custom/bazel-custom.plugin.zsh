# shellcheck disable=SC2148

if [[ -f ${HOME}/.config/coursier/credentials.properties ]]; then
  export COURSIER_CREDENTIALS=${HOME}/.config/coursier/credentials.properties
fi

# bazel_clean_disk_cache deletes cache file older than the time specified (60d by default)
function bazel_clean_disk_cache() {
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

# bazel_nuke_repository_cache deletes the contents of the repository_cache for the logged in user
function bazel_nuke_repository_cache() {
  rm -rf "$(bazel info repository_cache)"
}

# bazel_nuke_install_base deletes the contents of the install_base for the logged in user
function bazel_nuke_install_base() {
  rm -r "$(bazel info install_base)"
}

# bazel_nuke_other_caches deletes the contents of caches ties to the logged in user
function bazel_nuke_other_caches() {
  bazel_nuke_repository_cache
  bazel_nuke_install_base
}

# bazel_all run the given command over every resulting target for the given query
function bazel_all() {
  local command="${1}"
  shift
  bazel query "${@}" | xargs -n 1 bazel "${command}"
}

alias bazel-clean-disk-cache=bazel_clean_disk_cache
alias sri-hash=sri_hash
alias bazel-deps=bazel_deps
alias show-bazel-deps=show_bazel_deps
alias stbob='st "$(bazel info output_base)"'
alias bazel-nuke-repository-cache=bazel_nuke_repository_cache
alias bazel-nuke-install-base=bazel_nuke_install_base
alias bazel-nuke-other-caches=bazel_nuke_other_caches
alias bazel-all=bazel_all
