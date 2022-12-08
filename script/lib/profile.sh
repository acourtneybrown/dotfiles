# shellcheck shell=bash

PROFILE_SH_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
declare -a _finalizers

# shellcheck disable=SC1090,SC1091
. "${PROFILE_SH_DIR}/util.sh"

function profile::run_dotdrop_action() {
  local action="${1}"
  bash -c "$(yq eval ".actions.${action}" ../config.yaml)"
}

function profile::remove_ssh_key() {
  local key_file="${1}"

  rm -f "${key_file}"
}

function profile::get_ssh_key() {
  local key="${1}"
  local key_type
  key_type=$(op item get "${key}" --field "key type")

  local key_file="${HOME}/.ssh/id_${key_type}"

  if [[ ! -f "${key_file}" ]]; then
    mkdir -p "$(dirname "${key_file}")"
    touch "${key_file}"
    chmod 600 "${key_file}"
    op item get "${key}" --field 'private key' | tr -d \" >"${key_file}"
    _finalizers+=("profile::remove_ssh_key ${key_file}")
  else
    echo "${key_file} file already exists, skipping"
  fi
}

function profile::default() {
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile"

  # Install oh-my-zsh
  if [ ! -d ~/.oh-my-zsh ]; then
    if command -v curl >/dev/null; then
      sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    elif command -v wget >/dev/null; then
      sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -) --unattended"
    else
      util::abort "Either curl or wget must be installed"
    fi
  fi
}

function profile::default_after() {
  profile::enable_pyenv
  profile::enable_goenv
  pyenv global "$(profile::ensure_pyenv_version 3.11)"
  goenv global "$(profile::ensure_goenv_version 1.19)"
}

function profile::confluent() {
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile.confluent"

  profile::enable_pyenv
  profile::enable_goenv
  profile::enable_jenv

  mkdir -p "${HOME}/confluent"
  (
    cd "${HOME}/confluent" || return
    pyenv local "$(profile::ensure_pyenv_version 3.9)"
    goenv local "$(profile::ensure_goenv_version 1.18)"

    profile::jenv_sync_versions
    profile::jenv_enable_plugins

    jenv local 11.0
  )

  profile::pipx_install 3.11 gimme-aws-creds
}

function profile::confluent_after() {
  profile::get_ssh_key 'Default key'

  profile::run_dotdrop_action _cc_dotfiles_install

  # shellcheck disable=SC1090,SC1091
  source "${HOME}/.cc-dotfiles/include/devprod-ga/code-artifact.sh"
  export PATH="${HOME}/.local/bin:${PATH}"
  gimme-aws-creds --profile devprod-prod # force initial login
  code_artifact::pip_login

  profile::pipx_install 3.8 confluent-release-tools
  profile::pipx_install 3.9 confluent-ci-tools
  profile::pipx_install 3.11 ansible-hostmanager bump2version gql tox
}

function profile::confluent_totp() {
  profile::confluent
}

function profile::confluent_totp_after() {
  profile::confluent_after
}

function profile::personal() {
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile.personal"

  profile::enable_pyenv
  profile::enable_goenv

  profile::pipx_install 3.11 python-kasa python-vipaccess

  mkdir -p "${HOME}/personal"
  (
    cd "${HOME}/personal" || return

    pyenv local "$(profile::ensure_pyenv_version 3.11)"
    goenv local "$(profile::ensure_goenv_version 1.19)"
  )
}

function profile::linux() {
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile.linux"

  if [ -z "$(apt -qq list 1password-cli)" ]; then
    # Install 1Password CLI (https://developer.1password.com/docs/cli/get-started#install)
    curl -sS https://downloads.1password.com/linux/keys/1password.asc |
      sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" |
      sudo tee /etc/apt/sources.list.d/1password.list

    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol |
      sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc |
      sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

    sudo apt update && sudo apt install -qy 1password-cli
  fi
  sudo apt install -qy zsh

  # Install recommended dependencies for Python builds - https://github.com/pyenv/pyenv/wiki#troubleshooting--faq
  sudo apt install -qy make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
}

function profile::linux_after() {
  chsh -s /usr/bin/zsh
}

function profile::linux_desktop() {
  if [[ -z "$(apt -qq list sublime-text)" ]]; then
    # Install Sublime Text (https://www.sublimetext.com/docs/linux_repositories.html#apt)
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg |
      gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg >/dev/null

    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    sudo apt-get update && sudo apt-get install sublime-text
  fi
  sudo apt install -qy 1password
}

function profile::linux_desktop_after() {
  _finalizers+=("profile::op_forget_cli_login")
}

function profile::mac() {
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile.mac"
}

function profile::mac_after() {
  # install LaunchDaemon to ensure mosh is added to fw allow list
  "${PROFILE_SH_DIR}/install-fix-mosh"

  _finalizers+=("profile::op_forget_cli_login")
}

function profile::finalize() {
  for expr in "${_finalizers[@]}"; do
    eval "${expr}"
  done
}

function profile::ensure_brew_in_path() {
  if ! command -v brew >/dev/null; then
    export PATH="/usr/local/bin:/opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:$PATH"
  fi
}

function profile::ensure_brewfile_installed() {
  if [[ "${#}" -lt 1 ]]; then
    util::abort "Must specify Brewfile to install"
  fi
  local brewfile
  brewfile="${1}"

  profile::ensure_brew_in_path
  if [[ -f ${brewfile} ]]; then
    # We can't control if some packages fail to install, so don't exit out
    set +e
    brew bundle check --file "${brewfile}" >/dev/null 2>&1 || {
      echo "==> Installing Homebrew dependencies…"
      # mas signin  # uncomment when https://github.com/mas-cli/mas/issues/164 resolved
      brew bundle --file "${brewfile}"
    }
    set -e
  fi
}

function profile::ensure_command() {
  if [[ "${#}" -ne 1 ]]; then
    util::abort "called ensure_command with wrong arguments: ${*}"
  elif ! command -v "${1}" >/dev/null; then
    util::abort "Install ${1} first!"
  fi
}

function profile::enable_pyenv() {
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  eval "$(pyenv init -)"
}

function profile::enable_goenv() {
  export GOENV_ROOT="${HOME}/.goenv"
  export PATH="${GOENV_ROOT}/bin:${PATH}"
  eval "$(goenv init -)"
}

function profile::enable_jenv() {
  export PATH="${HOME}/.jenv/bin:${PATH}"
  eval "$(jenv init -)"
}

# pipx_install takes a version of Python installed via pyenv & installs a list of pipx packages with that version
function profile::pipx_install() {
  profile::ensure_command "pyenv"

  local to_install
  to_install=${1}
  shift

  local version
  version=$(profile::ensure_pyenv_version "${to_install}")
  local py_bin
  py_bin=$(PYENV_VERSION=${version} pyenv prefix)/bin/python
  local installed
  installed=$(pipx list --json | jq '.venvs')

  for package in "${@}"; do
    if [[ $(jq "has(\"${package}\")" <<<"${installed}") == "false" ]]; then
      pipx install "${package}" --python "${py_bin}"
    fi
  done
}

function profile::ensure_pyenv_version() {
  profile::ensure_command "pyenv"

  local to_install
  to_install=${1}

  # avoid outputing to stdout as the following line indicates the installed version, for later use
  pyenv install --skip-existing "$(pyenv latest --known "${to_install}")" >/dev/null
  pyenv latest "${to_install}"
}

function profile::ensure_goenv_version() {
  profile::ensure_command "goenv"

  local to_install
  to_install=${1}

  # avoid outputing to stdout as the following line indicates the installed version, for later use
  goenv install --skip-existing "$(goenv install -l | grep "${to_install}" | tail -1 | tr -d '[:space:]')" >/dev/null
  goenv install -l | grep "${to_install}" | tail -1 | tr -d '[:space:]'
}

# jenv_sync_versions makes sure that all installed JDKs are added to jenv
function profile::jenv_sync_versions() {
  profile::ensure_command "jenv"

  for dir in /Library/Java/JavaVirtualMachines/*; do
    jenv add "$dir/Contents/Home"
  done
}

function profile::jenv_enable_plugins() {
  jenvplugins=(maven gradle export)

  for jenvplugin in "${jenvplugins[@]}"; do
    if [[ ! -L "${HOME}/.jenv/plugins/${jenvplugin}" ]]; then
      jenv enable-plugin "${jenvplugin}"
    fi
  done
}

function profile::op_get_file() {
  local output
  output="${HOME}/${2}"

  if [[ -f "${output}" && ! -s "${output}" ]]; then
    echo "${2} is empty, removing it."
    rm "${output}"
  fi
  if [ -f "${output}" ]; then
    echo "${2} already exists."
    return
  fi
  echo "Extracting ${2}..."
  op document get "${1}" --output "${output}"
  chmod 600 "${output}"
}

function profile::op_forget_cli_login() {
  op signout --account my --forget
  op account forget --all
}

function profile::install_homebrew() {
  if util::is_linux; then
    case $(lsb_release --id --short) in
    Raspbian | Debian | Ubuntu)
      sudo apt install -qy build-essential procps curl file git
      ;;
    *)
      util::abort "Only Debian-based Linux distros are supported"
      ;;
    esac
  fi

  util::download_and_verify https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
    41d5eb515a76b43e192259fde18e6cd683ea8b6a3d7873bcfc5065ab5b12235c \
    /tmp/install.sh

  NONINTERACTIVE=1 bash /tmp/install.sh
  rm /tmp/install.sh

  echo "Updating Homebrew:"
  profile::ensure_brew_in_path
  brew update
}
