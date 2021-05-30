# shellcheck disable=SC2148

# Setup & activate python virtual env

# ve creates a virtualenv for the given name, or .venv/ if not given
function ve() {
  local env
  if [ $# -eq 0 ]; then
    env=.venv
  else
    env="$1"
  fi
  python3 -m venv "${env}"
}

# ve2 creates a virtualenv for Python2 for the given name, or .venv if not given
function ve2() {
  local env
  if [ $# -eq 0 ]; then
    env=.venv
  else
    env="$1"
  fi
  virtualenv "${env}"
}

# va activates a virtualenv for the given name, or .venv/ if present, or ~/.virtualenvs/<dir name>
function va() {
  local env
  if [ $# -eq 0 ]; then
    if [[ -d .venv ]]; then
      env=.venv
    elif [[ -d ~/.virtualenvs/$(basename "${PWD}") ]]; then
      env=~/.virtualenvs/$(basename "${PWD}")
    fi
  else
    env="$1"
  fi
  source "${env}/bin/activate"
}

alias pie.="pip install --editable ."
