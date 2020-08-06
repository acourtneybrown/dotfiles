# shellcheck disable=SC2148
# Ensure zmv function available
autoload -U zmv

# Opens a manpage in MacOS Preview
function man-preview() {
  man -t "$@" | open -f -a Preview
}

# cd to a directory & ls it
function cl() {
  DIR="$*"
  # if no DIR given, go home
  if [ $# -lt 1 ]; then
    DIR=$HOME
  fi
  builtin cd "${DIR}" &&
    # use your preferred ls command
    ls
}

# Show what process is listening on a port
listening() {
  if [ $# -eq 0 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P
  elif [ $# -eq 1 ]; then
    sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color "$1"
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
    history 1 | grep -E --color=auto "$@"
  fi
}

function disappointed() {
  echo -n " ಠ_ಠ " | tee /dev/tty | pbcopy
}

function flip() {
  echo -n "（╯°□°）╯ ┻━┻" | tee /dev/tty | pbcopy
}

function shrug() {
  echo -n "¯\_(ツ)_/¯" | tee /dev/tty | pbcopy
}

# open-syn opens the AFP mount on synology.notcharlie.com
function open-syn() {
  if [[ $# -eq 0 ]]; then
    echo "missing network mount"
    return 1
  fi

  open afp://synology.notcharlie.com/"$1"
}
