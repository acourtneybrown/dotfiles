# shellcheck disable=SC2148

if [[ -f ${HOME}/.config/coursier/credentials.properties ]]; then
  export COURSIER_CREDENTIALS=${HOME}/.config/coursier/credentials.properties
fi

export GOPRIVATE="github.com/confluentinc/*"

# clean_bazel_cache deletes cache file older than the time specified (60d by default)
function clean_bazel_cache() {
  local OLDER_THAN=${1:-60d}
  find "${HOME}/.cache/bazel" -type f -atime "+${OLDER_THAN}" -delete
}
