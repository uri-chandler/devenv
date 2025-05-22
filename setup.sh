#!/bin/bash

#####################################################################################################
#                                                                                                   #
# Logging Helpers                                                                                   #
#                                                                                                   #
#####################################################################################################

SCRIPT_NAME="devenv"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="setup-${TIMESTAMP}.log"
touch $LOG_FILE

# Define color codes
RESET="\033[0m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"

# Logging functions
log() {
  echo -e "${WHITE}[${CYAN}${SCRIPT_NAME}${WHITE}] $1${RESET}"
  echo -e "[${SCRIPT_NAME}] $1" | sed 's/\x1b\[[0-9;]*m//g' >> $LOG_FILE
}

warn() {
  echo -e "${WHITE}[${CYAN}${SCRIPT_NAME}${WHITE}] ${YELLOW}$1${RESET}"
  echo -e "[${SCRIPT_NAME}] $1" | sed 's/\x1b\[[0-9;]*m//g' >> $LOG_FILE
}

debug() {
  echo -e "${WHITE}[${CYAN}${SCRIPT_NAME}${WHITE}] ${BLUE}$1${RESET}"
  echo -e "[${SCRIPT_NAME}] $1" | sed 's/\x1b\[[0-9;]*m//g' >> $LOG_FILE
}

ok() {
  echo -e "${WHITE}[${CYAN}${SCRIPT_NAME}${WHITE}] ${GREEN}$1${RESET}"
  echo -e "[${SCRIPT_NAME}] $1" | sed 's/\x1b\[[0-9;]*m//g' >> $LOG_FILE
}

error() {
  echo -e "${WHITE}[${CYAN}${SCRIPT_NAME}${WHITE}] ${RED}$1${RESET}"
  echo -e "[${SCRIPT_NAME}] $1" | sed 's/\x1b\[[0-9;]*m//g' >> $LOG_FILE
}

# Example usage
#
# log "This is a standard log message."
# warn "This is a warning message."
# debug "This is a debug message."
# ok "This task is completed successfully."
# error "This is an error message."




#####################################################################################################
#                                                                                                   #
# Helper Functions                                                                                  #
#                                                                                                   #
#####################################################################################################

# Function to run a command and log output to the logfile
#
run() {
    command="$1"
    eval "$command" >> "$LOG_FILE" 2>&1
    return $?
}




#####################################################################################################
#                                                                                                   #
# Tools To Install                                                                                  #
#                                                                                                   #
#####################################################################################################

# Synax: "Name|Check Command|Install Command"
#
TOOLS=(
    # Xcode Command Line Tools
    "Xcode Command Line Tools|xcode-select -p|xcode-select --install"

    # Homebrew
    "Homebrew|brew --version|/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""

    # Oh My ZSH
    "Oh My ZSH|zsh --version|sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""

    # Volta
    "Volta|volta --version|/bin/bash -c \"\$(curl -fsSL https://get.volta.sh)\""

    # Node.js LTS using Volta
    "Node.js LTS|node --version|volta install node@lts"
)





#####################################################################################################
#                                                                                                   #
# ZSH Helpers To Install                                                                            #
#                                                                                                   #
#####################################################################################################

# Each helper will be installed by sourcing it in the .zshrc file
# and linking it to the .zsh_helpers directory
# Syntax: ".zsh_<TOOL_NAME>_helper"
ZSH_HELPERS=(
    "cloud"
    "docker"
    "git"
    "npm"
    "shell"
    "work"
)






#####################################################################################################
#                                                                                                   #
# Starting The Setup                                                                                #
#                                                                                                   #
#####################################################################################################

echo ""
log "Starting"

# Iterate over the list of TOOLS and check/install each one
#
for tool in "${TOOLS[@]}"; do

    # Line break for better readability
    echo "" | tee -a $LOG_FILE

    # Get the tool name, check command and install command
    IFS='|' read -r name check_cmd install_cmd <<< "$tool"
    
    # Log the tool name and check command
    log "Tool: ${CYAN}$name"
    warn " -> Checking if installed using: ${WHITE}$check_cmd"

    # Run the check command to see if the tool is already installed
    if ! run "$check_cmd"; then
        warn " -> Not found (installing)"

        # Try to install the tool
        # 
        if run "$install_cmd"; then
            ok " -> Installed completed successfully"
        else
            error " -> Failed to install $name (see $LOG_FILE for details)"
        fi
    else
        ok " -> Ok (already installed)"
    fi
done


# Make sure Homebrew is up-to-date
#
echo "" | tee -a $LOG_FILE
log "Updating Homebrew"
if run "brew update"; then
    ok " -> Homebrew updated successfully"
else
    error " -> Failed to update Homebrew (see $LOG_FILE for details)"
fi


# Install Homebrew apps and tools from Brewfile
#
echo "" | tee -a $LOG_FILE
log "Installing apps and tools from Brewfile (this might take a while)"
if run "brew bundle --file=~/devenv/Brewfile"; then
    ok " -> Brewfile installed successfully"
else
    error " -> Failed to install Brewfile (see $LOG_FILE for details)"
fi



# Iterate over the list of ZSH_HELPERS and check/install each one
#
for helper in "${ZSH_HELPERS[@]}"; do

    # Line break for better readability
    echo "" | tee -a $LOG_FILE
    log "Helper: ${CYAN}$helper.zsh"

    warn " -> Sourcing"
    if ! grep -Fxq "if [ -f ~/$helper.zsh ]; then source ~/$helper.zsh; fi" ~/.zshrc; then
        echo "if [ -f ~/$helper.zsh ]; then source ~/$helper.zsh; fi" >> ~/.zshrc
    fi

    warn " -> Linking"
    if [ ! -f ~/$helper.zsh ]; then
        ln -sf ~/devenv/zsh_helpers/$helper.zsh ~/$helper.zsh
    fi

    ok " -> Ok"
done




# Clean up old log files, keeping only the last 5
#
echo "" | tee -a $LOG_FILE
log "Cleaning up old log files"
ls -tp setup-*.log | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}
ok " -> Ok"