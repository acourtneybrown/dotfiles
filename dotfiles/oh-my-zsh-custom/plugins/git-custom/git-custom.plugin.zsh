# shellcheck disable=SC2148

# git-custom plugin should be added after oh-my-zsh's default git plugin to
# override some aliases to use origin's default branch instead of `master`

# `gdb` show the default branch for a git remote, defaulting
# to `origin` if no remote is specified
function gdb() {
  git symbolic-ref "refs/remotes/${1:-origin}/HEAD" | sed "s@^refs/remotes/${1:-origin}/@@"
}

# gupd` updates the default branch for a remote, defaulting
# to `origin` if no remote is specified
function gudb() {
  git remote set-head "${1:-origin}" -a
}

alias gbda='git branch --no-color --merged | command grep -vE "^(\+|\*|\s*(main|master|development|develop|devel|dev)\s*$)" | command xargs -n 1 git branch -d'

unalias gcm
unalias git-svn-dcommit-push
unalias glum
unalias gmom
unalias gmum
unalias grbm
unalias gpsup
unalias ggpush

alias gcdb='git checkout $(gdb)'
alias git-svn-dcommit-push='git svn dcommit && git push github $(gdb):svntrunk'
alias gludb='git pull upstream $(gdb)'
alias gmodb='git merge origin/$(gdb)'
alias gmudb='git merge upstream/$(gdb upstream)'
alias grbdb='git rebase $(gdb)'
alias gl="git pull --prune --tags"
alias gla="gl --all"
alias gcdbl="gcdb && gl"
alias gcdblff='gcdbl --ff-only'
alias gfodb='git fetch origin $(gdb):$(gdb)'
alias gfudb='git fetch upstream $(gdb upstream)'
alias gfu='git fetch upstream'
alias glr='git ls-remote'
alias gcob="gco -b"
alias grep_all="git branch -a | tr -d \* | sed '/->/d' | xargs git grep"

# gcobu checks out a new branch prefixed with the github username
# git checkout branch (for) username
function gcobu() {
  if [ "${#}" -lt 1 ]; then
    echo "Usage: gcobu <branch> [<starting_point>]"
    return
  fi
  local user
  user=$(git config github.user)
  local branch="${1}"
  shift
  git checkout -b "${user}/${branch}" "${@}"
}

# gdodb compares the origin's default branch to the specified branch (if given) or the current HEAD
# git diff origin default branch
function gdodb() {
  local branch="${1}"
  git diff "origin/$(gdb)...${branch}"
}

# gdob compares the origin's branch to the local tracking branch
# git diff origin branch
function gdob() {
  local branch
  branch=$(git symbolic-ref --short HEAD)
  git diff "origin/${branch}...${branch}"
}

# gdodb compares the upstream's default branch to the specified branch (if given) or the current HEAD
function gdudb() {
  local branch="${1}"
  git diff "upstream/$(gdb upstream)...${branch}"
}

# gitall performs a git operation across all of the git repositories under the
# current directory.
function gitall() {
  if [ "${#}" -lt 1 ]; then
    echo "Usage: gitall pull|push|commit ..."
    echo "Starts a git command for each directory found in current dir."
    return
  fi
  if tput setaf 1 &>/dev/null; then
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
  else
    BOLD=""
    RESET="\033[m"
  fi
  for DIR in *; do
    if [ -d "${DIR}/.git" ]; then
      echo "${BOLD}Entering ${DIR}${RESET}"
      git -C "${DIR}" "${@}"
    fi
  done
}

# gall performs a given command line across all of the git repositories under
# the current directory.  It also handles all aliases.
function gall() {
  if [ "${#}" -lt 1 ]; then
    echo "Usage: gall gcl|gcdb|..."
    echo "Starts a command for each directory found in current dir."
    return
  fi
  if tput setaf 1 &>/dev/null; then
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
  else
    BOLD=""
    RESET="\033[m"
  fi

  cmd=${1}
  # shellcheck disable=SC2154
  if [[ ${aliases[${1}]} ]]; then
    cmd=${aliases[${1}]}
  fi
  shift

  for DIR in *; do
    if [ -d "${DIR}/.git" ]; then
      echo "${BOLD}Entering ${DIR}${RESET}"
      (
        cd "${DIR}" || exit
        eval "${cmd}" "${@}"
      )
    fi
  done
}

# gpsup pushes the current branch to the specified remote (origin by default) & sets the upstream branch
function gpsup() {
  local remote
  if [ "${#}" -lt 1 ]; then
    remote=origin
  else
    remote="${1}"
  fi

  git push --set-upstream "${remote}" "$(git_current_branch)"
}

# ggpush pushes the current branch to the specified remote (origin by default)
function ggpush() {
  local remote
  if [ "${#}" -lt 1 ]; then
    remote=origin
  else
    remote="${1}"
  fi

  git push "${remote}" "$(git_current_branch)"
}

# ghclorg clones all of the repos under a GitHub org
function ghclorg() {
  local org
  if [ "${#}" -ne 1 ]; then
    echo "Usage: ghclorg <org>"
    return
  fi
  org="${1}"

  gh api "orgs/${org}/repos" --paginate --jq '.[].full_name' | xargs -n 1 -I % -P 6 -t git clone gh:%
}

# ghcluser clones all of the repos under a GitHub org
function ghcluser() {
  local user
  if [ "${#}" -ne 1 ]; then
    echo "Usage: ghcluser <org>"
    return
  fi
  user="${1}"

  gh api "users/${user}/repos" --paginate --jq '.[].full_name' | xargs -n 1 -I % -P 6 -t git clone gh:%
}
