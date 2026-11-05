if [[ ${commands[sbx]} ]]; then
  # shellcheck disable=SC2206
  path=(${path} "$(dirname "$(readlink "$(which sbx)")")")
  export LMSTUDIO_BASEURL="${LMSTUDIO_BASEURL:=http://localhost:1234/v1}"

  function _load_lms_api_key() {
    export LMSTUDIO_API_KEY="${LMSTUDIO_API_KEY:=$(op read "op://jrew5nqtk5aqdgupcoxqjuevwu/rbbgcx424dsim3tblf2s3kca34/credential")}"
  }

  function _discover_lms_models() {
    local response
    response=$(curl -sf -H "Authorization: Bearer $LMSTUDIO_API_KEY" LMSTUDIO_BASEURL/models 2>/dev/null) || return 0
    # shellcheck disable=SC2296
    LMSTUDIO_MODELS=("${(@f)$(echo "$response" | jq -r '.data[].id' 2>/dev/null)}")
  }

  LMSTUDIO_MODELS=()
  _lms_discovered=0

  function _ensure_lms_discovered() {
    if (( _lms_discovered )); then return; fi
    _load_lms_api_key
    _discover_lms_models
    _lms_discovered=1
  }

  function _sbx_model_for_dir() {
    local dir="$PWD"
    local model=""
    while true; do
      if [[ -f "$dir/.sbx-model" ]]; then
        model="$(cat "$dir/.sbx-model" 2>/dev/null)"
        break
      fi
      if [[ "$dir" == "$HOME" ]]; then
        break
      fi
      local parent="${dir:h}"
      if [[ "$parent" == "$dir" ]]; then
        break
      fi
      dir="$parent"
    done
    if [[ -n "$model" ]]; then
      print -r -- "$model"
      return 0
    fi
    return 1
  }

  function _sbx_model_available() {
    local model="$1"
    if (( ${#LMSTUDIO_MODELS} == 0 )); then
      return 0
    fi
    if [[ -n "${LMSTUDIO_MODELS[(r)$model]}" ]]; then
      return 0
    fi
    return 1
  }

  # shellcheck disable=SC2154
  function _sbx_run() {
    _ensure_lms_discovered
    local provider="$1"
    local cmd="$2"
    local model=""
    local pass_args=()
    local i=3
    local explicit=0

    while (( i <= $# )); do
      if [[ ${argv[i]} == "--model" && $((i+1 <= $#)) ]]; then
        model="${argv[i+1]}"
        explicit=1
        (( i += 2 ))
      else
        pass_args+=("${argv[i]}")
        (( i += 1 ))
      fi
    done

    if (( ! explicit )); then
      local dir_model
      dir_model="$(_sbx_model_for_dir)"
      if [[ -n "$dir_model" ]]; then
        model="$dir_model"
      fi
    fi

    if [[ -z "$model" ]]; then
      model="${LMSTUDIO_MODELS[1]:-}"
    fi

    if ! _sbx_model_available "$model"; then
      local fallback="${LMSTUDIO_MODELS[1]:-}"
      print -u2 "sbx: model '${model}' not available in LM Studio, falling back to '${fallback}'"
      model="$fallback"
    fi

    sbx run --provider "$provider" --model "$model" "$cmd" "${pass_args[@]}"
  }

  function sbxopencode() {
    _sbx_run lms-openai opencode "$@"
  }

  function sbxclaude() {
    _sbx_run lms-anthropic claude "$@"
  }

  function sbxcodex() {
    _sbx_run lms-openai codex "$@"
  }

  function sbx-models() {
    _ensure_lms_discovered
    if (( ${#LMSTUDIO_MODELS} > 0 )); then
      print -l "${LMSTUDIO_MODELS[@]}"
    else
      print -u2 "no models available"
    fi
  }

  function sbx-global() {
    _ensure_lms_discovered
    if (( $# == 0 )); then
      local model=""
      model="$(cat "$HOME/.sbx-model" 2>/dev/null)"
      if [[ -n "$model" ]]; then
        print -r -- "$model"
        return 0
      fi
      print -u2 "sbx_global: no global model set in ~/.sbx-model"
      return 1
    fi
    local model="$1"
    if ! _sbx_model_available "$model"; then
      print -u2 "sbx_global: '${model}' is not a valid LM Studio model"
      return 1
    fi
    print "$model" > "$HOME/.sbx-model"
    print -r -- "$model"
  }

  function sbx-local() {
    _ensure_lms_discovered
    if (( $# == 0 )); then
      local dir_model
      dir_model="$(_sbx_model_for_dir)"
      if [[ -n "$dir_model" ]]; then
        print -r -- "$dir_model"
        return 0
      fi
      print -u2 "sbx_local: no local model set (.sbx-model)"
      return 1
    fi
    local model="$1"
    if ! _sbx_model_available "$model"; then
      print -u2 "sbx_local: '${model}' is not a valid LM Studio model"
      return 1
    fi
    print "$model" > "$PWD/.sbx-model"
    print -r -- "$model"
  }

  # shellcheck disable=SC2154
  function _sbx_model_complete() {
    _ensure_lms_discovered
    if [[ ${words[CURRENT-1]} == "--model" ]]; then
      compadd -Q -- "${LMSTUDIO_MODELS[@]}"
    elif [[ ${words[CURRENT]} == -* ]]; then
      compadd -Q -- "--model"
    fi
  }
  compdef _sbx_model_complete sbxopencode sbxclaude sbxcodex
fi
