alias rmf='rm -rf'
alias notes='code ~/notes'
alias aliases='code ~/.zsh_aliases'



# Create a directory and cd into it
#
mkcd() { mkdir -p "$1" && cd "$1" }


# Assert that the projects dir exists,
# and cd into it.
#
# If a project name is provided, create a directory for it
# and cd into it.
#
cdp() {
  mkdir -p ~/projects

  if [ -z "$1" ]; then
    cd ~/projects
  else
    mkdir -p "~/projects/$1" && cd "~/projects/$1"
  fi
}