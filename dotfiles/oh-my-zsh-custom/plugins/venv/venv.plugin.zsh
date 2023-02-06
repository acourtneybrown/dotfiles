# shellcheck disable=SC2148

# Setup & activate python virtual env

# ve creates a virtualenv for the given name, or .venv/ if not given
function ve() {
  local env=${1:-.venv}
  python3 -m venv "${env}"
}

# ve2 creates a virtualenv for Python2 for the given name, or .venv if not given
function ve2() {
  local env=${1:-.venv}
  virtualenv "${env}"
}

# va activates a virtualenv for the given name, or .venv/ if present, or ${HOME}/.virtualenvs/<dir name>
function va() {
  local env
  if [[ ${#} -eq 0 ]]; then
    if [[ -d .venv ]]; then
      env=.venv
    elif [[ -d ${HOME}/.virtualenvs/$(basename "${PWD}") ]]; then
      env=${HOME}/.virtualenvs/$(basename "${PWD}")
    fi
  else
    env="${1}"
  fi
  # shellcheck disable=SC1090,SC1091
  source "${env}/bin/activate"
}

alias pie.="pip install --editable ."
