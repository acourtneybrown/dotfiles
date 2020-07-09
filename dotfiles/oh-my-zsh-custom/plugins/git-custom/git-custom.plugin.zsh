# git-custom plugin should be added after oh-my-zsh's default git plugin to
# override some aliases to use origin's default branch instead of `master`

function gdb() {
  git symbolic-ref "refs/remotes/${1:-origin}/HEAD" | sed "s@^refs/remotes/${1:-origin}/@@"
}

function gudb() {
  git remote set-head "${1:-origin}" -a
}

alias gbda='git branch --no-color --merged | command grep -vE "^(\+|\*|\s*(main|master|development|develop|devel|dev)\s*$)" | command xargs -n 1 git branch -d'
alias gcm='git checkout $(gdb)'
alias git-svn-dcommit-push='git svn dcommit && git push github $(gdb):svntrunk'
alias glum='git pull upstream $(gdb)'
alias gmom='git merge origin/$(gdb)'
alias gmum='git merge upstream/$(gdb upstream)'
alias grbm='git rebase $(gdb)'
