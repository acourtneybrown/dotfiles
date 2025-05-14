# shellcheck shell=bash

INSTALL_SH_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# shellcheck disable=SC1090,SC1091
. "${INSTALL_SH_DIR}/util.sh"

STDIN_FILE_DESCRIPTOR="0"
[[ -t "$STDIN_FILE_DESCRIPTOR" ]] && DOTFILES_INTERACTIVE="1"

function install::mac_update_nfs() {
  if ! grep 'nfs.client.mount.options = intr,locallocks,nfc' /etc/nfs.conf; then
    echo 'nfs.client.mount.options = intr,locallocks,nfc' | sudo tee -a /etc/nfs.conf
  fi
}

function install::os_updates() {
  if util::is_mac; then
    install::mac_updates
  elif util::is_linux; then
    install::linux_updates
  fi
}

# install:mac_updates checks for macOS software updates & installs them
function install::mac_updates() {
  if softwareupdate -l 2>&1 | grep -q "No new software available."; then
    echo "No software updates to install"
  else
    echo "Installing software updates:"
    sudo softwareupdate --install --all
    install::xcode_license
  fi
}

function install::linux_updates() {
  case $(lsb_release --id --short) in
  Raspbian | Debian | Ubuntu)
    sudo apt autoremove -qy
    sudo apt update && sudo apt upgrade -qy
    ;;
  *)
    util::abort "Only Debian-based Linux distros are supported"
    ;;
  esac
}

function install::install_xcode() {
  if ! [[ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]]; then
    log "Installing the Xcode Command Line Tools:"
    CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo touch "${CLT_PLACEHOLDER}"

    CLT_PACKAGE=$(softwareupdate -l |
      grep -B 1 "Command Line Tools" |
      awk -F"*" '/^ *\*/ {print $2}' |
      sed -e 's/^ *Label: //' -e 's/^ *//' |
      sort -V |
      tail -n1)
    sudo softwareupdate -i "${CLT_PACKAGE}"
    sudo rm -f "${CLT_PLACEHOLDER}"
    if ! [[ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]]; then
      if [[ -n "${DOTFILES_INTERACTIVE}" ]]; then
        echo "Requesting user install of Xcode Command Line Tools:"
        xcode-select --install
      else
        util::abort "Run 'xcode-select --install' to install the Xcode Command Line Tools."
      fi
    fi
  fi

  install::xcode_license
}

# xcode_license checks if the Xcode license is agreed to and agree if not.
function install::xcode_license() {
  if /usr/bin/xcrun clang 2>&1 | grep -q license; then
    if [[ -n "${DOTFILES_INTERACTIVE}" ]]; then
      echo "Asking for Xcode license confirmation:"
      sudo xcodebuild -license accept
    else
      util::abort "Run 'sudo xcodebuild -license' to agree to the Xcode license."
    fi
  fi
}

# install_rosetta2 attempts to install Rosetta2, assuming on ARM-based Mac
function install::install_rosetta2() {
  softwareupdate --install-rosetta --agree-to-license
}

function install::ensure_samba_no_mangles_names() {
  local SMB_CONF="/etc/samba/smb.conf"
  local TMP_CONF
  TMP_CONF=$(mktemp "${TMPDIR:-/tmp}/smb.conf.tmp.XXXXXX")
  local KEY="mangled names"
  local VALUE="no"
  local KEY_LINE="$KEY=$VALUE"

  # Backup first
  cp "$SMB_CONF" "${SMB_CONF}.$(date +"%Y-%m-%d_%H-%M-%S").bak"

  awk -v key="$KEY" -v value="$VALUE" -v line="$KEY_LINE" '
    BEGIN { in_global = 0; key_updated = 0 }

    /^\[global\]/ {
      in_global = 1
      print
      next
    }

    /^\[.*\]/ {
      if (in_global && !key_updated) {
        print line
        key_updated = 1
      }
      in_global = 0
      print
      next
    }

    {
      if (in_global && $0 ~ "^" key "[[:space:]]*=") {
        print line
        key_updated = 1
      } else {
        print
      }
    }

    END {
      if (in_global && !key_updated) {
        print line
      }
    }
  ' "$SMB_CONF" | sudo tee "$TMP_CONF" && sudo mv "$TMP_CONF" "$SMB_CONF"
}

function install::ensure_home_mount() {
  if [[ ! -f /etc/systemd/system/home.mount ]]; then
    sudo install -m 755 "${INSTALL_SH_DIR}/resources/home.mount" /etc/systemd/system/home.mount
    sudo chmod 755 /var/services/homes
    sudo mkdir -m 755 /home            # Create /home directory
    sudo systemctl daemon-reload       # Reload systemd services
    sudo systemctl enable home.mount   # Enable the service to be mounted on startup
    sudo systemctl start home.mount    # Mount the /home volume
  fi
}

function install::ensure_linuxbrew_home() {
  if [[ ! -d /home/linuxbrew ]]; then
    sudo mkdir -m 755 /home/linuxbrew
  fi
}

function install::ensure_ldd() {
  [[ -f /usr/bin/ldd ]] || sudo install -m 755 "${INSTALL_SH_DIR}/resources/fake_ldd" /usr/bin/ldd
}

function install::ensure_os-release() {
  local pretty_name
  # shellcheck disable=SC1091,SC2154
  pretty_name=$(source /etc.defaults/VERSION && echo "${os_name} ${productversion}-${buildnumber} Update ${smallfixnumber}")

  [[ -f /etc/os-release ]] || sudo install -m 755 /dev/stdin /etc/os-release <<EOF
PRETTY_NAME="$pretty_name"
EOF
}
