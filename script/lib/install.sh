# shellcheck shell=bash

# shellcheck disable=SC1091
. util.sh

function install::mac_update_nfs() {
  if ! grep 'nfs.client.mount.options = intr,locallocks,nfc' /etc/nfs.conf; then
    echo 'nfs.client.mount.options = intr,locallocks,nfc' | sudo tee -a /etc/nfs.conf
  fi
}

function install::os_updates() {
  util::is_mac && install::mac_updates
  util::is_linux && install::linux_updates
}

# install:mac_updates checks for macOS software updates & installs them
function install:mac_updates() {
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
