# Ensure zmv function available
autoload -U zmv

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
