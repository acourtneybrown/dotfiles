# shellcheck disable=SC2148

alias opsignin='eval $(op signin my)'

# pswd puts the password of the named service into the clipboard
function pswd() {
    (( $# < 1 )) && echo "Usage: pswd <service>"
    local service=$1

    (( ! oploggedin )) && opsignin

    op get item $service | jq -r '.details.fields[] | select(.designation=="password").value' | pbcopy

    ( sleep 5 && op get totp $service | pbcopy
      sleep 10 && pbcopy < /dev/null 2>&1 & ) &!

}

function oploggedin() {
    op list users &> /dev/null
}
