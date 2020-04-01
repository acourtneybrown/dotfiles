# Ensure zmv function available
autoload -U zmv

# `gitall` performs a git operation across all of the git repositories under the
# current directory.
function gitall {
  if [ "$#" -lt 1  ]; then
    echo "Usage: gitall pull|push|commit ..."
    echo "Starts a git command for each directory found in current dir."
    return
  fi
  if tput setaf 1 &> /dev/null; then
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
  else
    BOLD=""
    RESET="\033[m"
  fi
  for DIR in `ls`;
  do
    if [ -d $DIR/.git ]; then
      echo $BOLD"Entering "$DIR$RESET
      (cd $DIR; git "$@")
    fi
  done
}

# Opens a manpage in MacOS Preview
function man-preview() {
	man -t "$@" | open -f -a Preview
}

# cd to a directory & ls it
function cl() {
    DIR="$*";
        # if no DIR given, go home
        if [ $# -lt 1 ]; then
                DIR=$HOME;
    fi;
    builtin cd "${DIR}" && \
    # use your preferred ls command
        ls
}

# Show what process is listening on a port
listening() {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

# Print history or search it
function h() {
    # check if we passed any parameters
    if [ -z "$*" ]; then
        # if no parameters were passed print entire history
        history 1
    else
        # if words were passed use it as a search
        history 1 | egrep --color=auto "$@"
    fi
}

disappointed() { echo -n " ಠ_ಠ " |tee /dev/tty| pbcopy }

flip() { echo -n "（╯°□°）╯ ┻━┻" |tee /dev/tty| pbcopy }

shrug() { echo -n "¯\_(ツ)_/¯" |tee /dev/tty| pbcopy }

# Alias to fix mosh-server Mac firewall problems
function fix_mosh_server() {

  # local variables for convenience
  local fw='/usr/libexec/ApplicationFirewall/socketfilterfw'
  local mosh_sym="$(which mosh-server)"
  local mosh_abs="$(greadlink -f $mosh_sym)"

  # temporarily shut firewall off
  sudo "$fw" --setglobalstate off

  # add symlinked location to firewall
  sudo "$fw" --add "$mosh_sym"
  sudo "$fw" --unblockapp "$mosh_sym"

  # add symlinked location to firewall
  sudo "$fw" --add "$mosh_abs"
  sudo "$fw" --unblockapp "$mosh_abs"

  # re-enable firewall
  sudo "$fw" --setglobalstate on
}

