# shellcheck shell=bash

PROFILE_SH_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
declare -a _finalizers

# shellcheck disable=SC1091
. "${PROFILE_SH_DIR}/util.sh"

function profile::run_dotdrop_action() {
  local action="${1}"
  bash -c "$(yq eval ".actions.${action}" ../config.yaml)"
}

function profile::default() {
  local tmpscript
  tmpscript=$(mktemp /tmp/install.sh.XXXXXX)
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile"

  # Install oh-my-zsh
  if [[ ! -d ~/.oh-my-zsh ]]; then
    if [ "$(
      util::download_and_verify https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
        fbfcd1c0bf99acfcf77f7f999d75bb8c833d3b58643b603b3971d8cd1991fc2e \
        "$tmpscript"
    )" != "ok" ]; then
      util::abort "oh-my-zsh install script changed"
    fi

    sh $tmpscript --unattended
    rm -f "$tmpscript"
  fi
}

function profile::default_after() {
  profile::enable_pyenv
  profile::enable_goenv
  pyenv global "$(profile::ensure_pyenv_version 3.11)"
  goenv global "$(profile::ensure_goenv_version 1.19)"
}

function profile::personal() {
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile.personal"

  profile::enable_pyenv
  profile::enable_goenv

  profile::pipx_install 3.11 python-kasa python-vipaccess tox twine pytest build
}

function profile::linux() {
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile.linux"

  if [[ -z "$(apt -qq list 1password-cli)" ]]; then
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

function profile::synology() {
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile.synology"

  profile::install_op_cli_manual
}

function profile::install_op_cli_manual() {
  # install 1Password CLI tool
  local ARCH="amd64"
  local OP_VERSION="2.30.3"
  local tmpdir

  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}"/op-cli.XXXXXXXXXX)" || return
  if [ "$(util::download_and_verify "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_${ARCH}_v${OP_VERSION}.zip" \
    a16307ebcecb40fd091d7a6ff4f0c380c3c0897c4f4616de2c5d285e57d5ee28 \
    "${tmpdir}/op.zip")" != "ok" ]; then
    util::abort "1password-cli zipfile changed"
  fi
  unzip -d "${tmpdir}/op" "${tmpdir}/op.zip"
  sudo mv "${tmpdir}/op"/op /usr/local/bin/
  rm -rf "$tmpdir"
  sudo groupadd -f onepassword-cli
  sudo chgrp onepassword-cli /usr/local/bin/op
  sudo chmod g+s /usr/local/bin/op
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
  brew tap --force homebrew/cask
  profile::ensure_brewfile_installed "${PROFILE_SH_DIR}/resources/Brewfile.mac"
}

function profile::mac_after() {
  profile::install_fix_mosh
  if [[ ! $(whoami) == virtualbuddy ]]; then
    # Avoid issues with exhausting device licenses during testing
    profile::handle_betterdisplay_license
  fi
  profile::configure_calibre

  _finalizers+=("profile::op_forget_cli_login")
}

# install LaunchDaemon to ensure mosh is added to fw allow list
function profile::install_fix_mosh() {
  local RESOURCES
  RESOURCES="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/resources

  # create target destination
  mkdir -p "/Users/Shared/.startup"

  # put files in correct locations for LaunchDaemon
  if [[ ! -f "/Users/Shared/.startup/mosh.sh" ]]; then
    echo "Installing LaunchDaemon & script for mosh..."

    sudo cp "${RESOURCES}/mosh.sh" "/Users/Shared/.startup/mosh.sh"
    sudo cp "${RESOURCES}/com.mosh.plist" "/Library/LaunchDaemons/com.mosh.plist"

    # create correct file permissions
    sudo chmod 644 "/Users/Shared/.startup/mosh.sh"
    sudo chmod 644 "/Library/LaunchDaemons/com.mosh.plist"

    # create correct file ownerships
    sudo chown root:wheel "/Users/Shared/.startup/mosh.sh"
    sudo chown root:wheel "/Library/LaunchDaemons/com.mosh.plist"

    # add mosh launch daemon
    sudo launchctl load -w "/Library/LaunchDaemons/com.mosh.plist"
  fi
}

function profile::handle_betterdisplay_license() {
  if /Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay manageLicense -status | grep -q "Not activated"; then
    /Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay manageLicense \
      -activate \
      -email="$(op read "op://Adam/BetterDisplay/Customer/registered email")" \
      -key="$(op read "op://Adam/BetterDisplay/license key")"
  fi
}

function profile::configure_calibre() {
  local tmpdir
  local dedrm_version
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}"/calibre-dedrm.XXXXXXXXXX)" || return
  dedrm_version="10.0.9"

  op plugin run -- gh release -R noDRM/DeDRM_tools download --dir "$tmpdir" "v${dedrm_version}"
  unzip -x "$tmpdir/DeDRM_tools_${dedrm_version}.zip" -d "${tmpdir}/DeDRM_tools_${dedrm_version}"
  calibre-customize --add-plugin "${tmpdir}/DeDRM_tools_${dedrm_version}/DeDRM_Plugin.zip"
  calibre-customize --add-plugin "${tmpdir}/DeDRM_tools_${dedrm_version}/Obok_Plugin.zip"

  if [ "$(util::download_and_verify https://plugins.calibre-ebook.com/291290.zip \
    23f074cace458103fb0b07432579cb240b458385b92771f9529b22b07cd1ed24 \
    "${tmpdir}/KFX Input.zip")" != "ok" ]; then
    util::abort "KFX Input.zip file changed"
  fi
  calibre-customize --add-plugin "${tmpdir}/KFX Input.zip"

  rm -rf "$tmpdir"
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
    else
      pipx reinstall "${package}" --python "${py_bin}"
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
  if [[ -f "${output}" ]]; then
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

  if [ "$(util::download_and_verify https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
    a30b9fbf0d5c2cff3eb1d0643cceee30d8ba6ea1bb7bcabf60d3188bd62e6ba6 \
    /tmp/install.sh)" != "ok" ]; then
    util::abort "Homebrew install script changed"
  fi

  NONINTERACTIVE=1 bash /tmp/install.sh
  rm /tmp/install.sh

  echo "Updating Homebrew:"
  profile::ensure_brew_in_path
  brew update
}
