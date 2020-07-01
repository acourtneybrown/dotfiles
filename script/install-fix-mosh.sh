#!/bin/sh
# Adapted from https://github.com/mobile-shell/mosh/issues/898
# and https://gist.github.com/sriramkswamy/9cd9887eafb6d4d27a754dcc8d9bd4b1

SOURCE="$(cd `dirname $0` && pwd)"
. script/functions

echo "Installing LaunchDaemon & script for mosh..."

# create target destination
mkdir -p "/Users/Shared/.startup"

# put files in correct locations for LaunchDaemon
sudo cp "${SOURCE}/mosh.sh" "/Users/Shared/.startup/mosh.sh"
sudo cp "${SOURCE}/com.mosh.plist" "/Library/LaunchDaemons/com.mosh.plist"

# create correct file permissions
sudo chmod 644 "/Users/Shared/.startup/mosh.sh"
sudo chmod 644 "/Library/LaunchDaemons/com.mosh.plist"

# create correct file ownerships
sudo chown root:wheel "/Users/Shared/.startup/mosh.sh"
sudo chown root:wheel "/Library/LaunchDaemons/com.mosh.plist"

# add mosh launch daemon
sudo launchctl load -w "/Library/LaunchDaemons/com.mosh.plist"
