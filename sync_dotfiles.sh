#!/bin/bash

# Dotfiles Auto-Sync Script
# Monitors changes in config files and automatically commits/pushes to the dotfiles git repo

DOTFILES_DIR="/Users/piacsek/dotfiles"
LOG_FILE="$DOTFILES_DIR/.sync.log"

# Configuration directories to watch and their corresponding dotfiles paths
CONFIG_SOURCE="$HOME/.config/nvim"
CONFIG_DEST="$DOTFILES_DIR/nvim"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to sync config files to dotfiles repo
sync_config_files() {
    if [[ -d "$CONFIG_SOURCE" ]]; then
        log_message "Syncing $CONFIG_SOURCE to $CONFIG_DEST"
        
        # Create dotfiles directory if it doesn't exist
        mkdir -p "$CONFIG_DEST"
        
        # Use rsync to sync files, excluding common unwanted files
        rsync -av --delete \
            --exclude='.DS_Store' \
            --exclude='*.tmp' \
            --exclude='*.swp' \
            --exclude='*.log' \
            "$CONFIG_SOURCE/" "$CONFIG_DEST/"
    else
        log_message "Warning: Config directory $CONFIG_SOURCE does not exist"
    fi
}

# Function to commit and push changes
sync_changes() {
    cd "$DOTFILES_DIR" || exit 1
    
    # First sync config files to dotfiles repo
    sync_config_files
    
    # Check if there are any changes
    if [[ -n $(git status --porcelain) ]]; then
        log_message "Changes detected, syncing..."
        
        # Add all changes
        git add .
        
        # Create commit message with timestamp and changed files
        CHANGED_FILES=$(git diff --cached --name-only | tr '\n' ' ')
        COMMIT_MSG="Auto-sync dotfiles: $CHANGED_FILES - $(date '+%Y-%m-%d %H:%M:%S')"
        
        # Commit changes
        if git commit -m "$COMMIT_MSG"; then
            log_message "Committed: $COMMIT_MSG"
            
            # Push to remote
            if git push origin master; then
                log_message "Successfully pushed to remote"
            else
                log_message "ERROR: Failed to push to remote"
            fi
        else
            log_message "ERROR: Failed to commit changes"
        fi
    else
        log_message "No changes detected"
    fi
}

# Function to start file monitoring
start_monitoring() {
    log_message "Starting dotfiles synchronization monitoring..."
    
    # Check if fswatch is installed
    if ! command -v fswatch &> /dev/null; then
        echo "fswatch is not installed. Install it with: brew install fswatch"
        exit 1
    fi
    
    # Check if config directory exists
    if [[ ! -d "$CONFIG_SOURCE" ]]; then
        log_message "Error: Config directory $CONFIG_SOURCE does not exist"
        exit 1
    fi
    
    log_message "Monitoring config directory: $CONFIG_SOURCE"
    
    # Monitor the config directory for changes
    # Exclude common temporary/unwanted files
    fswatch -o \
        --exclude='\.DS_Store' \
        --exclude='\.tmp' \
        --exclude='\.swp' \
        --exclude='\.log' \
        --latency=2 \
        "$CONFIG_SOURCE" | while read -r
    do
        log_message "File system event detected in config directories"
        # Add a small delay to avoid multiple rapid commits
        sleep 1
        sync_changes
    done
}

# Function to perform one-time sync
one_time_sync() {
    log_message "Performing one-time sync..."
    sync_changes
}

# Main script logic
case "${1}" in
    "monitor")
        start_monitoring
        ;;
    "sync")
        one_time_sync
        ;;
    "status")
        cd "$DOTFILES_DIR" || exit 1
        git status
        ;;
    *)
        echo "Usage: $0 [monitor|sync|status]"
        echo "  monitor  - Start continuous file monitoring (default)"
        echo "  sync     - Perform one-time sync"
        echo "  status   - Show git status"
        exit 1
        ;;
esac
