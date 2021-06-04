# shellcheck disable=SC2148

alias opsignin='eval $(op signin my)'

function oploggedin() {
  op list users &>/dev/null
}

# pswd puts the password of the named service into the clipboard
function pswd() {
  ((${#} < 1)) && echo "Usage: pswd <service>"
  local service="${1}"

  ! oploggedin && opsignin

  local password

  if password=$(op get item "${service}" --fields password 2>/dev/null); then
    echo "${password}" | pbcopy

    local totp
    if totp=$(op get totp "${service}" 2>/dev/null); then
      (
        sleep 5
        echo "${totp}" | pbcopy
        echo "TOTP ready"
      ) &!
    fi

    (
      sleep 15
      pbcopy </dev/null
      echo "password cleared"
    ) &!
  else
    echo "No entry in 1Password for ${service}"
  fi
}
