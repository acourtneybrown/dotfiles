# shellcheck disable=SC2148

# Install command line completions for pipx & ensure it's bin/ is added to the path

# shellcheck disable=SC2154
if [[ ${commands[pipx]} ]]; then
  if [[ -d "${HOME}/.local/bin" ]]; then
    # Actually *want* path to be split
    # shellcheck disable=2206
    path=("${HOME}/.local/bin" ${path})
  fi
  _evalcache register-python-argcomplete pipx

  # pipx_install takes a version of Python installed via pyenv & installs a list of pipx packages with that version
  function pipx_install() {
    local version
    version=${1}
    shift

    local py_bin
    py_bin=$(PYENV_VERSION=${version} pyenv prefix)/bin/python
    local installed
    installed=$(pipx list --json | jq '.venvs')

    for package in "${@}"; do
      if [[ $(jq "has(\"${package}\")" <<<"${installed}") == "false" ]]; then
        pipx install "${package}" --python "${py_bin}"
      else
        pipx reinstall "${package}" --python "${py_bin}"
      fi
    done
  }
fi
