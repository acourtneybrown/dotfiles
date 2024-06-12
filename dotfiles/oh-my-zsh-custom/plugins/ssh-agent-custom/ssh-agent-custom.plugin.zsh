() {
  # Get the filename to store/lookup the environment from
  local ssh_env_cache="$HOME/.ssh/environment-$SHORT_HOST"

  # Check if ssh-agent is already running
  if [[ -f "$ssh_env_cache" ]]; then
    . "$ssh_env_cache" >/dev/null

    # Test if $SSH_AUTH_SOCK is visible
    zmodload zsh/net/socket
    if [[ -S "$SSH_AUTH_SOCK" ]] && zsocket "$SSH_AUTH_SOCK" 2>/dev/null; then
      return 0
    fi
  fi

  if [[ ! -d "$HOME/.ssh" ]]; then
    echo "[oh-my-zsh] ssh-agent plugin requires ~/.ssh directory"
    return 1
  fi

  # Set a maximum lifetime for identities added to ssh-agent
  local lifetime
  zstyle -s :omz:plugins:ssh-agent lifetime lifetime

  # start ssh-agent and setup environment
  zstyle -t :omz:plugins:ssh-agent quiet || echo >&2 "Starting ssh-agent ..."
  ssh-agent -s ${lifetime:+-t} ${lifetime} | sed '/^echo/d' >! "$ssh_env_cache"
  chmod 600 "$ssh_env_cache"
  . "$ssh_env_cache" >/dev/null
}
