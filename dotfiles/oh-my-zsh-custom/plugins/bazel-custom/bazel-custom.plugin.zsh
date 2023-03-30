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

# bazel_deps outputs the dependency graph for a given Bazel target (default //...)
function bazel_deps() {
  local target
  target="${1-//...}"
  bazel query --notool_deps --noimplicit_deps "deps(${target})" --output graph
}

alias bazel-clean-cache=bazel_clean_cache
alias bazel-deps=bazel_deps
