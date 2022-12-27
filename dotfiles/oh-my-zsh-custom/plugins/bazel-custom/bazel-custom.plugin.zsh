# shellcheck disable=SC2148

if [[ -f ~/.config/coursier/credentials.properties ]]; then
  export COURSIER_CREDENTIALS=~/.config/coursier/credentials.properties
fi

export GOPRIVATE="github.com/confluentinc/*"
