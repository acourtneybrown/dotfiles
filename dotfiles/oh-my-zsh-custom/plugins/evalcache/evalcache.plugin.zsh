# shellcheck disable=SC2148

# Caches the output of a binary initialization command, to avoid the time to
# execute it in the future.
#
# Usage: _evalcache <command> <generation args...>

# default cache directory
export ZSH_EVALCACHE_DIR=${ZSH_EVALCACHE_DIR:-"$HOME/.zsh-evalcache"}

function _evalcache() {
  local cmdHash="nohash"

  if builtin command -v md5 >/dev/null; then
    cmdHash=$(echo -n "$*" | md5)
  elif builtin command -v md5sum >/dev/null; then
    cmdHash=$(echo -n "$*" | md5sum | cut -d' ' -f1)
  fi

  local cacheFile="$ZSH_EVALCACHE_DIR/init-${1##*/}-${cmdHash}.sh"

  if [ "$ZSH_EVALCACHE_DISABLE" = "true" ]; then
    eval "$("$@")"
  elif [ -s "$cacheFile" ]; then
    # shellcheck disable=SC1090
    source "$cacheFile"
  else
    if type "$1" >/dev/null; then
      (echo >&2 "$1 initialization not cached, caching output of: $*")
      mkdir -p "$ZSH_EVALCACHE_DIR"
      "$@" >"$cacheFile"
      # shellcheck disable=SC1090
      source "$cacheFile"
    else
      echo "evalcache ERROR: $1 is not installed or in PATH"
    fi
  fi
}

function _evalcache_clear() {
  rm -i "$ZSH_EVALCACHE_DIR"/init-*.sh
}
