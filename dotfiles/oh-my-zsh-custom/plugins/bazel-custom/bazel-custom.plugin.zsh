# shellcheck disable=SC2148

if [[ -f ${HOME}/.config/coursier/credentials.properties ]]; then
  export COURSIER_CREDENTIALS=${HOME}/.config/coursier/credentials.properties
fi

export GOPRIVATE="github.com/confluentinc/*"

# bazel_clean_cache deletes cache file older than the time specified (60d by default)
function bazel_clean_cache() {
  local OLDER_THAN=${1:-60d}
  find "${HOME}/.cache/bazel" -type f -atime "+${OLDER_THAN}" -delete
}
alias bazel-clean-cache=bazel_clean_cache

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
alias sri-hash=sri_hash
