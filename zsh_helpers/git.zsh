alias add='git add'
alias gitl="git log --graph --abbrev-commit --decorate --pretty=format:'%h - %an : %s'"
alias pull='git pull'
alias stash='git --no-pager stash'
alias status='git status'
alias commit='git commit'
alias branch='git branch'
alias checkout='git checkout'


# Push, but also set the upstream branch if it doesn't exist
#
push() {
  git push "$@" 2>&1 || {
    current_branch=$(git symbolic-ref --short HEAD);
    echo "Upstream not set for branch $current_branch. Setting it now.";
    git push --set-upstream origin "$current_branch";
  }
}