# shellcheck disable=SC2148

if [ -d "$(brew --prefix)/opt/mariadb-connector-c" ]; then
  path+="$(brew --prefix)/opt/mariadb-connector-c/bin"
  # shellcheck disable=SC2155
  export LD_LIBRARY_PATH="$(brew --prefix)/opt/mariadb-connector-c/lib":${LD_LIBRARY_PATH}
  typeset -U LD_LIBRARY_PATH
fi
