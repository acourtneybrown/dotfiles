# shellcheck shell=bash

MACOS_SH_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# shellcheck disable=SC1090,SC1091
. "${MACOS_SH_DIR}/util.sh"

function macos::add_to_array_if_not_present() {
  local domain
  local key
  local value

  domain=$1
  key=$2
  value=$3
  (defaults read "$domain" "$key" | grep -q "$value") || defaults write "$domain" "$key" -array-add "$value"
}

function macos::setup() {
  [[ "${USER}" = "root" ]] && util::abort "Run macos as yourself, not root."
  groups | grep -q admin || util::abort "Add ${USER} to the admin group."

  util::sudo_keepalive

  # Close any open System Preferences panes, to prevent them from overriding
  # settings we’re about to change
  osascript -e 'tell application "System Preferences" to quit'

  [[ -z "${DOTFILES_SKIP_LOGIN_WINDOW}" ]] && macos::setup_login_window

  macos::setup_screen
  macos::setup_ui_ux
  macos::setup_security
  macos::setup_input_devices
  macos::setup_apple_intelligence

  local apps
  apps=(
    Finder
    Dock
    Safari
    iTerm
    "Time Machine"
    "Activity Monitor"
    "App Store"
    Photos
    Messages
    Music
    "Google Chrome"
    Contacts
    Dashboard
    iCal
    TextEdit
    DiskUtility
    "QuickTime Player"
    Alfred
    BetterDisplay
  )
  local fn
  for app in "${apps[@]}"; do
    fn="macos::config_${app// /_}"
    echo "${app} -> ${fn}"
    "${fn}"
    echo "${fn} done"
  done

  macos::kill_apps
  macos::finalize
}

function macos::setup_login_window() {
  local COMPUTER_NAME
  local LOGIN_NAME
  local LOGIN_EMAIL

  # Set computer name (as done via System Preferences → Sharing)
  echo "Enter computer name. Leave empty to not change."
  read -r COMPUTER_NAME
  if [[ -n "${COMPUTER_NAME}" ]]; then
    sudo scutil --set ComputerName "${COMPUTER_NAME}"
    sudo scutil --set HostName "${COMPUTER_NAME}"
    sudo scutil --set LocalHostName "${COMPUTER_NAME}"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"
  fi

  # Set the login window contact info
  echo "Enter your name (for login screen message). Leave empty to not change."
  read -r LOGIN_NAME
  echo "Enter your email address (for login screen message). Leave empty to not change."
  read -r LOGIN_EMAIL
  if [[ -n "${LOGIN_NAME}" ]] && [[ -n "${LOGIN_EMAIL}" ]]; then
    LOGIN_TEXT=$(util::escape "Found this computer? Please contact ${LOGIN_NAME} at ${LOGIN_EMAIL}.")
    echo "${LOGIN_TEXT}" | grep -q '[()]' && LOGIN_TEXT="'${LOGIN_TEXT}'"
    sudo defaults write /Library/Preferences/com.apple.loginwindow \
      LoginwindowText \
      "${LOGIN_TEXT}"
  fi
}

function macos::setup_screen() {
  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  defaults -currentHost write com.apple.screensaver idleTime -int 0
  defaults -currentHost write com.apple.screensaver lastDelayTime -int 1200
  defaults -currentHost write com.apple.screensaver tokenRemovalAction -int 0

  # Save screenshots to the desktop
  defaults write com.apple.screencapture location -string "${HOME}/Desktop"

  # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"

  # Disable shadow in screenshots
  defaults write com.apple.screencapture disable-shadow -bool true

  # Enable subpixel font rendering on non-Apple LCDs
  # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
  defaults write NSGlobalDomain AppleFontSmoothing -int 1

  # Enable HiDPI display modes (requires restart)
  sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true
}

function macos::setup_ui_ux() {
  # Set standby delay to 24 hours (default is 1 hour)
  sudo pmset -a standbydelay 86400

  # Disable sleep when connected to display
  sudo pmset -a sleep 0

  # Set how long to delay sleep on charger & battery
  sudo pmset -c displaysleep 10
  sudo pmset -b displaysleep 2

  # Set sidebar icon size to medium
  # defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

  # Always show scrollbars
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
  # Possible values: `WhenScrolling`, `Automatic` and `Always`

  # Disable the over-the-top focus ring animation
  defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

  # Adjust toolbar title rollover delay
  defaults write NSGlobalDomain NSToolbarTitleViewRolloverDelay -float 0

  # Increase window resize speed for Cocoa applications
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Automatically quit printer app once the print jobs complete
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  # Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

  # Display ASCII control characters using caret notation in standard text views
  # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
  defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

  # Set Help Viewer windows to non-floating mode
  defaults write com.apple.helpviewer DevMode -bool true

  # Reveal IP address, hostname, OS version, etc. when clicking the clock
  # in the login window
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

  # Restart automatically if the computer freezes
  sudo systemsetup -setrestartfreeze on

  # Turn on remote login via SSH & remove password-based logins
  sudo cp /etc/ssh/sshd_config{,.sav}

  cat <<EOF | sudo tee -a /etc/ssh/sshd_config

# Disable password-based logins
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
EOF

  sudo systemsetup -setremotelogin on

  # Turn on Remote Management (for screen sharing)
  # sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  #   -activate -configure -access -on -users admin -privs -all -restart -agent -menu

  # Disable automatic capitalization as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  # Disable smart dashes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Disable automatic period substitution as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  # Disable smart quotes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Set a custom wallpaper image. `DefaultDesktop.jpg` is already a symlink, and
  # all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
  #rm -rf ~/Library/Application Support/Dock/desktoppicture.db
  #sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
  #sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg

  # Sound: show volume in menu bar
  defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.volume" -bool true
  macos::add_to_array_if_not_present com.apple.systemuiserver menuExtras "/System/Library/CoreServices/Menu Extras/Volume.menu"
  defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true
  defaults -currentHost write com.apple.controlcenter Sound -int 18

  # TimeMachine: show icon in menu bar
  defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine" -bool true
  macos::add_to_array_if_not_present com.apple.systemuiserver menuExtras "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"

  # Bluetooth: show icon in menu bar
  defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool true
  macos::add_to_array_if_not_present com.apple.systemuiserver menuExtras "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"
  defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
  defaults write com.apple.controlcenter "NSStatusItem Visible Item-2" -bool false
  defaults write com.apple.controlcenter "NSStatusItem Preferred Position Bluetooth" -int 160
  defaults -currentHost write com.apple.controlcenter Bluetooth -int 2

  # VPN: show icon in menu bar
  defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.vpn" -bool true
  macos::add_to_array_if_not_present com.apple.systemuiserver menuExtras "/System/Library/CoreServices/Menu Extras/VPN.menu"

  # Time & Clock: Show date in menu bar
  defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"

  # Battery: show icon in menu bar
  defaults write "com.apple.menuextra.battery" ShowPercent YES
  defaults write com.apple.controlcenter "NSStatusItem Visible Battery" -bool true
  defaults -currentHost write com.apple.controlcenter Battery -int 2
  defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -int 1

  # Disable Handoff
  defaults -currentHost write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool false
  defaults -currentHost write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool false

  # Disable Universal Control
  defaults -currentHost write com.apple.universalcontrol Disable -bool true

  # Display Script menu in menu bar
  defaults write com.apple.scriptmenu ScriptMenuEnabled -bool true
  open '/System/Library/CoreServices/Script Menu.app'
}

function macos::setup_security() {
  # Enable the firewall
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist 2>/dev/null

  if fdesetup status | grep -q -E "FileVault is (On|Off, but will be enabled after the next restart)."; then
    echo "FileVault enabled"
  else
    echo "Enabling full-disk encryption on next reboot:"
    sudo fdesetup enable -user "${USER}" |
      tee ~/Desktop/"FileVault Recovery Key.txt"
    echo "Recovery key on Desktop"
  fi

  # Check and, if necessary, enable sudo authentication using TouchID.
  # Don't care about non-alphanumeric filenames when doing a specific match
  # shellcheck disable=SC2010
  if ls /usr/lib/pam | grep -q "pam_tid.so"; then
    echo "Configuring sudo authentication using TouchID:"
    if [[ -f /etc/pam.d/sudo_local || -f /etc/pam.d/sudo_local.template ]]; then
      # New in macOS Sonoma, survives updates.
      PAM_FILE="/etc/pam.d/sudo_local"
      FIRST_LINE="# sudo_local: local config file which survives system update and is included for sudo"
      if [[ ! -f "/etc/pam.d/sudo_local" ]]; then
        echo "$FIRST_LINE" | sudo tee "$PAM_FILE" >/dev/null
      fi
    else
      PAM_FILE="/etc/pam.d/sudo"
      FIRST_LINE="# sudo: auth account password session"
    fi
    if grep -q pam_tid.so "${PAM_FILE}"; then
      echo "ok"
    elif ! head -n1 "${PAM_FILE}" | grep -q "${FIRST_LINE}"; then
      echo "${PAM_FILE} is not in the expected format!"
    else
      TOUCHID_LINE="auth       sufficient     pam_tid.so"
      sudo sed -i .bak -e \
        "s/${FIRST_LINE}/${FIRST_LINE}\n${TOUCHID_LINE}/" \
        "${PAM_FILE}"
      sudo rm "${PAM_FILE}.bak"
      echo "ok"
    fi
  fi
}

function macos::setup_input_devices() {
  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Swipe between full screen apps with 4 fingers
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -bool false
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -bool false

  # Mission control & App expose with 4 fingers
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -bool false
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -bool false
  defaults write com.apple.dock showMissionControlGestureEnabled -bool true
  defaults write com.apple.dock showAppExposeGestureEnabled -bool true

  # Accessibility - Enable dragging w/ three fingers
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

  # Accessibility - Use scroll gesture with Control (^) modifier key to zoom
  defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask -int 262144
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad HIDScrollZoomModifierMask -int 262144
  defaults write com.apple.universalaccess closeViewHotkeysPreviouslyEnabled -bool false
  defaults write com.apple.universalaccess closeViewScrollWheelPreviousToggle -bool true
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true

  # Disable “natural” (Lion-style) scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

  # Keyboard: default touchbar to function keys
  defaults write com.apple.touchbar.agent PresentationModeGlobal -string functionKeys

  # Keyboard: touchbar Fn keys to "Show Control Strip"
  defaults write com.apple.touchbar.agent PresentationModeFnModes -dict fullControlStrip functionKeys functionKeys fullControlStrip

  # Keyboard: default functions keys to F1, F2, etc
  defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

  # Increase sound quality for Bluetooth headphones/headsets
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

  # Enable full keyboard access for all controls
  # (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Disable press-and-hold for keys in favor of key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # Set language and text formats
  # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
  # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
  defaults write NSGlobalDomain AppleLanguages -array "en"
  defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
  defaults write NSGlobalDomain AppleMetricUnits -bool false

  # Set the timezone; see `sudo systemsetup -listtimezones` for other values
  # sudo systemsetup -settimezone "America/Phoenix" >/dev/null

  # Don't display keyboard/language selector
  defaults write "com.apple.TextInputMenu" visible -bool false

  # Update keyboard shortcuts for screenshots to not conflict with Firefox Multi-Account Containers
  defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 184 "
    <dict>
      <key>enabled</key><true/>
      <key>value</key><dict>
        <key>type</key><string>standard</string>
        <key>parameters</key>
        <array>
          <integer>53</integer>
          <integer>23</integer>
          <integer>1703936</integer>
        </array>
      </dict>
    </dict>
  "
  defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 28 "
    <dict>
      <key>enabled</key><true/>
      <key>value</key><dict>
        <key>type</key><string>standard</string>
        <key>parameters</key>
        <array>
          <integer>51</integer>
          <integer>20</integer>
          <integer>1703936</integer>
        </array>
      </dict>
    </dict>
  "
  defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 30 "
    <dict>
      <key>enabled</key><true/>
      <key>value</key><dict>
        <key>type</key><string>standard</string>
        <key>parameters</key>
        <array>
          <integer>52</integer>
          <integer>21</integer>
          <integer>1703936</integer>
        </array>
      </dict>
    </dict>
  "

  # Disable "Search With ..." from the Services menu
  defaults write pbs NSServicesStatus -dict-add "com.apple.Safari - Search With %WebSearchProvider@ - searchWithWebSearchProvider" "
    <dict>
      <key>enabled_context_menu</key><false/>
      <key>enabled_services_menu</key><false/>
      <key>presentation_modes</key><dict>
        <key>ContextMenu</key><false/>
        <key>ServicesMenu</key><false/>
      </dict>
    </dict>
  "
  /System/Library/CoreServices/pbs -update
}

# function macos::setup_ssd_tweaks() {
# Disable hibernation (speeds up entering sleep mode)
# sudo pmset -a hibernatemode 0

# Remove the sleep image file to save disk space
# sudo rm /private/var/vm/sleepimage
# Create a zero-byte file instead…
# sudo touch /private/var/vm/sleepimage
# …and make sure it can’t be rewritten
# sudo chflags uchg /private/var/vm/sleepimage
# }

# function macos::setup_hot_corners() {
# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Top left screen corner → Mission Control
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → Desktop
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → Start screen saver
# defaults write com.apple.dock wvous-bl-corner -int 5
# defaults write com.apple.dock wvous-bl-modifier -int 0
# }

function macos::getMobileMeAccountID() {
  /usr/libexec/PlistBuddy -c "print Accounts:0:AccountDSID" "${HOME}/Library/Preferences/MobileMeAccounts.plist"
}

function macos::setup_apple_intelligence() {
  local mobileMeAccountID

  # disable Apple Intelligence
  case $- in
    *e*)
      set +e
      mobileMeAccountID=$(macos::getMobileMeAccountID)
      set -e
      ;;
    *)
      mobileMeAccountID=$(macos::getMobileMeAccountID)
  esac

  if [[ "${mobileMeAccountID}" == *"File Doesn't Exist"* ]]; then
    defaults write com.apple.CloudSubscriptionFeatures.optIn device -bool "false"
  else
    defaults write com.apple.CloudSubscriptionFeatures.optIn "$mobileMeAccountID" -bool "false"
  fi
}

function macos::config_Finder() {
  # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
  defaults write com.apple.finder QuitMenuItem -bool true

  # Finder: disable window animations and Get Info animations
  # defaults write com.apple.finder DisableAllAnimations -bool true

  # Set home folder as the default location for new Finder windows
  # For other paths, use `PfLo` and `file:///full/path/here/`
  # For Desktop, use `PfDe` and `file://${HOME}/Desktop/`
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

  # Show icons for hard drives, servers, and removable media on the desktop
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  # Finder: show hidden files by default
  # defaults write com.apple.finder AppleShowAllFiles -bool true

  # Finder: show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Display full POSIX path as Finder window title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Disable the warning when changing a file extension
  # defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Enable spring loading for directories
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true

  # Remove the spring loading delay for directories
  defaults write NSGlobalDomain com.apple.springing.delay -float 0

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Automatically open a new Finder window when a volume is mounted
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

  # Show item info near icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  # /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

  # Show item info to the right of the icons on the desktop
  /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

  # Enable snap-to-grid for icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  # /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

  # Increase grid spacing for icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
  # /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

  # Increase the size of icons on the desktop and in other icon views
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
  # /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

  # Use list view in all Finder windows by default
  # Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # Disable the warning before emptying the Trash
  # defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Enable AirDrop over Ethernet and on unsupported Macs running Lion
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

  # Show the ~/Library folder
  chflags nohidden ~/Library

  # Show the /Volumes folder
  sudo chflags nohidden /Volumes

  # Expand the following File Info panes:
  # “General”, “Open with”, and “Sharing & Permissions”
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true
}

function macos::config_Dock() {
  # Enable highlight hover effect for the grid view of a stack (Dock)
  defaults write com.apple.dock mouse-over-hilite-stack -bool true

  # Set the icon size of Dock items to 36 pixels
  defaults write com.apple.dock tilesize -int 36

  # Change minimize/maximize window effect
  defaults write com.apple.dock mineffect -string "scale"

  # Minimize windows into their application’s icon
  defaults write com.apple.dock minimize-to-application -bool true

  # Enable spring loading for all Dock items
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true

  # Wipe all (default) app icons from the Dock
  # This is only really useful when setting up a new Mac, or if you don’t use
  # the Dock to launch apps.
  # defaults write com.apple.dock persistent-apps -array

  # Show only open applications in the Dock
  # defaults write com.apple.dock static-only -bool true

  # Don’t animate opening applications from the Dock
  # defaults write com.apple.dock launchanim -bool false

  # Speed up Mission Control animations
  defaults write com.apple.dock expose-animation-duration -float 0.1

  # Don’t group windows by application in Mission Control
  # (i.e. use the old Exposé behavior instead)
  defaults write com.apple.dock expose-group-by-app -bool false

  # Disable Dashboard
  defaults write com.apple.dashboard mcx-disabled -bool true

  # Don’t show Dashboard as a Space
  defaults write com.apple.dock dashboard-in-overlay -bool true

  # Don’t automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false

  # Remove the auto-hiding Dock delay
  defaults write com.apple.dock autohide-delay -float 0
  # Remove the animation when hiding/showing the Dock
  # defaults write com.apple.dock autohide-time-modifier -float 0

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool true

  # Make Dock position on right
  defaults write com.apple.dock orientation -string right

  # Make Dock show 10 recent apps
  defaults write com.apple.dock show-recents -bool true
  defaults write com.apple.dock show-recent-count -int 10
}

function macos::config_Safari() {
  # Privacy: don’t send search queries to Apple
  defaults write com.apple.Safari UniversalSearchEnabled -bool false
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true

  # Press Tab to highlight each item on a web page
  defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

  # Show the full URL in the address bar (note: this still hides the scheme)
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

  # Set Safari’s home page to `about:blank` for faster loading
  defaults write com.apple.Safari HomePage -string "about:blank"

  # Prevent Safari from opening ‘safe’ files automatically after downloading
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

  # Allow hitting the Backspace key to go to the previous page in history
  # defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

  # Hide Safari’s bookmarks bar by default
  defaults write com.apple.Safari ShowFavoritesBar -bool false

  # Hide Safari’s sidebar in Top Sites
  defaults write com.apple.Safari ShowSidebarInTopSites -bool false

  # Disable Safari’s thumbnail cache for History and Top Sites
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

  # Enable Safari’s debug menu
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

  # Make Safari’s search banners default to Contains instead of Starts With
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

  # Remove useless icons from Safari’s bookmarks bar
  defaults write com.apple.Safari ProxiesInBookmarksBar "()"

  # Enable the Develop menu and the Web Inspector in Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  # Add a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  # Enable continuous spellchecking
  defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
  # Disable auto-correct
  defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

  # Disable AutoFill
  defaults write com.apple.Safari AutoFillFromAddressBook -bool false
  defaults write com.apple.Safari AutoFillPasswords -bool false
  defaults write com.apple.Safari AutoFillCreditCardData -bool false
  defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

  # Warn about fraudulent websites
  defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

  # Disable plug-ins
  defaults write com.apple.Safari WebKitPluginsEnabled -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

  # Disable Java
  defaults write com.apple.Safari WebKitJavaEnabled -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
  defaults write com.apple.Safari \
    com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles \
    -bool false

  # Block pop-up windows
  defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

  # Disable auto-playing video
  # defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
  # defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
  # defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
  # defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

  # Enable “Do Not Track”
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

  # Update extensions automatically
  defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

  # Set default search to DuckDuckGo
  defaults write com.apple.Safari SearchProviderShortName -string DuckDuckGo
  defaults write com.apple.Safari WBSOfflineSearchSuggestionsModelGoogleWasDefaultSearchEngineKey -bool false
  defaults write "Apple Global Domain" NSPreferredWebServices -dict NSWebServicesProviderWebSearch \
    '{
        "NSDefaultDisplayName" = "DuckDuckGo";
        "NSProviderIdentifier" = "com.duckduckgo";
    }';
}

function macos::config_iTerm() {
  # read config from ~/.config/iterm2
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

  # shellcheck disable=SC2088
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.config/iterm2"

  defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true
  defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -bool false

  # Use macOS system window restore
  defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true

  # Turn off Secure Keyboard Entry
  defaults write com.googlecode.iterm2 "Secure Input" -bool false
}

function macos::config_Time_Machine() {
  # Prevent Time Machine from prompting to use new hard drives as backup volume
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  local excluded=(
    "${HOME}/Dropbox"
    "${HOME}/Parallels"
    "${HOME}/Virtual Machines.localized"
    "${HOME}/Shared with me"
    "${HOME}/SynologyDrive"
    "${HOME}/temp"
  )
  local dir_existed
  for exclusion in "${excluded[@]}"; do
    dir_existed=true
    if ! tmutil isexcluded "${exclusion}" | grep -q '\[Excluded\]'; then
      [[ -d "${exclusion}" ]] || {
        mkdir -p "${exclusion}"
        dir_existed=false
      }
      sudo tmutil addexclusion -p "${exclusion}"
      if [[ ${dir_existed} == false ]]; then
        rmdir "${exclusion}"
      fi
    fi
  done
}

function macos::config_Activity_Monitor() {
  # Show the main window when launching Activity Monitor
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

  # Visualize CPU usage in the Activity Monitor Dock icon
  defaults write com.apple.ActivityMonitor IconType -int 5

  # Show all processes in Activity Monitor
  defaults write com.apple.ActivityMonitor ShowCategory -int 0

  # Sort Activity Monitor results by CPU usage
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0
}

function macos::config_App_Store() {
  # Enable the WebKit Developer Tools in the Mac App Store
  defaults write com.apple.appstore WebKitDeveloperExtras -bool true

  # Enable Debug Menu in the Mac App Store
  defaults write com.apple.appstore ShowDebugMenu -bool true

  # Enable the automatic update check
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

  # Check for software updates daily, not just once per week
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

  # Download newly available updates in background
  defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

  # Install System data files & security updates
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

  # Turn on app auto-update
  defaults write com.apple.commerce AutoUpdate -bool true

  # Allow the App Store to reboot machine on macOS updates
  defaults write com.apple.commerce AutoUpdateRestartRequired -bool true
}

function macos::config_Photos() {
  # Prevent Photos from opening automatically when devices are plugged in
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
}

function macos::config_Messages() {
  # Disable automatic emoji substitution (i.e. use plain text smileys)
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

  # Disable smart quotes as it’s annoying for messages that contain code
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

  # Disable continuous spell checking
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false
}

function macos::config_Music() {
  # Disable Apple Music & iTunes Store
  defaults write com.apple.Music showStoreInSidebar -int 1
  defaults write com.apple.Music showAppleMusic -bool false
}

function macos::config_Google_Chrome() {
  # Disable the all too sensitive backswipe on trackpads
  defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
  defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

  # Disable the all too sensitive backswipe on Magic Mouse
  defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
  defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

  # Use the system-native print preview dialog
  defaults write com.google.Chrome DisablePrintPreview -bool true
  defaults write com.google.Chrome.canary DisablePrintPreview -bool true

  # Expand the print dialog by default
  defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
  defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true
}

function macos::config_Contacts() {
  # Enable the debug menu in Address Book
  /usr/libexec/PlistBuddy -c "print" ~/Library/Preferences/com.apple.AddressBook.plist
  defaults write com.apple.AddressBook ABShowDebugMenu -bool true
}

function macos::config_Dashboard() {
  # Enable Dashboard dev mode (allows keeping widgets on the desktop)
  defaults write com.apple.dashboard devmode -bool true
}

function macos::config_iCal() {
  # Enable the debug menu in iCal (pre-10.8)
  defaults write com.apple.iCal IncludeDebugMenu -bool true
}

function macos::config_TextEdit() {
  # Use plain text mode for new TextEdit documents
  defaults write com.apple.TextEdit RichText -int 0

  # Open and save files as UTF-8 in TextEdit
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
}

function macos::config_DiskUtility() {
  # Enable the debug menu in Disk Utility
  defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
  defaults write com.apple.DiskUtility advanced-image-options -bool true
}

function macos::config_QuickTime_Player() {
  # Auto-play videos when opened with QuickTime Player
  defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true
}

function macos::config_Alfred() {
  # Change Spotlight shortcut
  defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 64 "
    <dict>
      <key>enabled</key><true/>
      <key>value</key><dict>
        <key>type</key><string>standard</string>
        <key>parameters</key>
        <array>
          <integer>32</integer>
          <integer>49</integer>
          <integer>917504</integer>
        </array>
      </dict>
    </dict>
  "
}

function macos::config_BetterDisplay() {
  if ! defaults read pro.betterdisplay.BetterDisplay >/dev/null 2>&1; then
    plutil -convert binary1 -o - "${MACOS_SH_DIR}/resources/BetterDisplay.plist" |
      defaults import pro.betterdisplay.BetterDisplay -
  else
    echo "BetterDisplay preferences already set.  Will not overwrite."
    echo "Run 'script/update-betterdisplay-plist' to compare via git"
  fi
}

function macos::kill_apps() {
  set +e
  for app in "Activity Monitor" \
    "Address Book" \
    "Calendar" \
    "cfprefsd" \
    "Contacts" \
    "Dock" \
    "Finder" \
    "Google Chrome Canary" \
    "Google Chrome" \
    "iTerm2" \
    "Mail" \
    "Messages" \
    "Music" \
    "Photos" \
    "Safari" \
    "SystemUIServer" \
    "iCal" \
    "Alfred" \
    "BetterDisplay" \
    ; do
    killall "${app}" &>/dev/null
  done
  echo "Done. Note that some of these changes require a logout/restart to take effect."
}

function macos::finalize() {
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
}
