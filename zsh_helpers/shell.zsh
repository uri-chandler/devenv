# In your .zshrc or .bashrc
# alias brew='brew "$@" && (cd /path/to/your/brewfile/repo && brew bundle dump --force && git commit -am "Update Brewfile" && git push)'

alias rmf='rm -rf'
alias aliases='code ~/devenv/zsh_helpers'
alias wf=watchfiles
alias lg=lazygit
source /Users/uri-chandler/.config/broot/launcher/bash/br

# Create a directory and cd into it
#
mkcd() { mkdir -p "$1" && cd "$1" }


# Assert that the projects dir exists,
# and cd into it.
#
# If a project name is provided, create a directory for it
# and cd into it.
#
cdp () {
    local base="$HOME/projects"
    mkdir -p "$base" || return

    if [ -z "${1//[[:space:]]/}" ]; then
        cd "$base" || return
    else
        mkdir -p "$base/$1" && cd "$base/$1" || return
    fi
}
