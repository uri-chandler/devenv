#!/bin/bash
set -euo pipefail

DEVENV_DIR="$HOME/devenv"
cd "$DEVENV_DIR"

#####################################################################################################
#                                                                                                   #
# Logging Helpers                                                                                   #
#                                                                                                   #
#####################################################################################################

SCRIPT_NAME="devenv"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="update-${TIMESTAMP}.log"
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
# Starting The Update                                                                                #
#                                                                                                   #
#####################################################################################################

echo ""
log "Starting"


# STEP 1) Update Brewfile
#
echo "" | tee -a $LOG_FILE
log "Updating Brewfile"
if run "brew bundle dump --file=\"$DEVENV_DIR/Brewfile\" --force"; then
    ok " -> Brewfile updated successfully"
else
    error " -> Failed to update Brewfile (see $LOG_FILE for details)"
fi


# STEP 2) Copy VSCode settings
#
echo "" | tee -a $LOG_FILE
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
if [[ -f "$VSCODE_SETTINGS" ]]; then
    log "Found VSCode settings"

    mkdir -p "$DEVENV_DIR/vscode"
    if run "cp -f \"$VSCODE_SETTINGS\" \"$DEVENV_DIR/vscode/settings.json\""; then
        ok " -> VSCode settings updated successfully"
    else
        error " -> Failed to copy VSCode settings (see $LOG_FILE for details)"
    fi
fi

# STEP 3) Copy VSCode keybindings
#
echo "" | tee -a $LOG_FILE
VSCODE_KEYBINDINGS="$HOME/Library/Application Support/Code/User/keybindings.json"
if [[ -f "$VSCODE_KEYBINDINGS" ]]; then
    log "Found VSCode keybindings"
    mkdir -p "$DEVENV_DIR/vscode"
    if run "cp -f \"$VSCODE_KEYBINDINGS\" \"$DEVENV_DIR/vscode/keybindings.json\""; then
        ok " -> VSCode keybindings updated successfully"
    else
        error " -> Failed to copy VSCode keybindings (see $LOG_FILE for details)"
    fi
fi


# STEP 4) Commit and push if there are changes
#
echo "" | tee -a $LOG_FILE
log "Checking for changes to commit"
if ! git diff --quiet || ! git diff --cached --quiet; then
    
    # git add
    if run "git add ."; then
        ok " -> Staged changes for commit"
    else
        error " -> Failed to stage changes for commit (see $LOG_FILE for details)"
    fi

    # git commit
    if run "git commit -m \"chore(setup): update Brewfile and VS Code extensions ($(date -u +%Y-%m-%dT%H:%MZ))\""; then
        ok " -> Committed changes successfully"
    else
        error " -> Failed to commit changes (see $LOG_FILE for details)"
    fi

    # git pull --rebase
    if run "git pull --rebase"; then
        ok " -> Rebased changes successfully"
    else
        error " -> Failed to rebase changes (see $LOG_FILE for details)"
    fi

    # git push
    if run "git push"; then
        ok " -> Pushed changes successfully"
    else
        error " -> Failed to push changes (see $LOG_FILE for details)"
    fi

else
    echo "No changes to commit."
fi



# Clean up old log files, keeping only the last 5
#
log "Cleaning up old log files"
ls -tp update-*.log | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}
ok " -> Ok"
echo "" | tee -a $LOG_FILE