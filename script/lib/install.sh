# shellcheck shell=bash

INSTALL_SH_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# shellcheck disable=SC1090,SC1091
. "${INSTALL_SH_DIR}/util.sh"

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
    abort "Only Debian-based Linux distros are supported"
    ;;
  esac
}

function install::install_xcode() {
  if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
    log "Installing the Xcode Command Line Tools:"
    CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
    sudo_askpass touch "$CLT_PLACEHOLDER"

    CLT_PACKAGE=$(softwareupdate -l |
      grep -B 1 "Command Line Tools" |
      awk -F"*" '/^ *\*/ {print $2}' |
      sed -e 's/^ *Label: //' -e 's/^ *//' |
      sort -V |
      tail -n1)
    sudo_askpass softwareupdate -i "$CLT_PACKAGE"
    sudo_askpass rm -f "$CLT_PLACEHOLDER"
    if ! [ -f "/Library/Developer/CommandLineTools/usr/bin/git" ]; then
      if [ -n "$STRAP_INTERACTIVE" ]; then
        echo "Requesting user install of Xcode Command Line Tools:"
        xcode-select --install
      else
        abort "Run 'xcode-select --install' to install the Xcode Command Line Tools."
      fi
    fi
  fi

  install::xcode_license
}

# xcode_license checks if the Xcode license is agreed to and agree if not.
function install::xcode_license() {
  if /usr/bin/xcrun clang 2>&1 | grep -q license; then
    if [ -n "${STRAP_INTERACTIVE}" ]; then
      echo "Asking for Xcode license confirmation:"
      sudo xcodebuild -license accept
    else
      abort "Run 'sudo xcodebuild -license' to agree to the Xcode license."
    fi
  fi
}
