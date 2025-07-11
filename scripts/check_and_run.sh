#!/bin/bash

SCRIPT_TO_RUN="/usr/local/scripts/check-script.sh"
LOG_FILE="/var/log/check_script.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Create log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    # Initialize with healthy state
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Status: 0 (Service is healthy) - Initial state" > "$LOG_FILE"
fi

# Function to get the last status from log file
get_last_status() {
    if [ -f "$LOG_FILE" ]; then
        # Extract the last status number from the log file
        local last_status=$(tail -n 1 "$LOG_FILE" | grep -o 'Status: [0-9]\+' | grep -o '[0-9]\+')
        if [ -n "$last_status" ]; then
            echo "$last_status"
            return
        fi
    fi
    echo "0"  # Default status if no log exists or no status found
}

# Get status message based on exit code
get_status_message() {
    local status=$1    # Explicitly local
    local message=""   # Explicitly local
    
    case $status in
        0) message="Service is healthy" ;;
        1) message="Service is unhealthy" ;;
        2) message="Service is in transition state" ;;
        *) message="Unknown status" ;;
    esac
    
    echo "$message"
}

# Logging function
log_status() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local status=$1
    local message=$2
    local status_message=$(get_status_message "$status")
    echo "$timestamp - Status: $status ($status_message) - $message" >> "$LOG_FILE"
}

if [ -x "$SCRIPT_TO_RUN" ]; then
    echo "Running script: $SCRIPT_TO_RUN"
    "$SCRIPT_TO_RUN"
    EXIT_STATUS=$?  # Capture the exit status of the called script
    
    # Get previous status from log
    PREV_STATUS=$(get_last_status)
    
    # Only log if status has changed
    if [ "$EXIT_STATUS" != "$PREV_STATUS" ]; then
        log_status "$EXIT_STATUS" "State change detected"
    fi
else
    echo "Script not found or not executable: $SCRIPT_TO_RUN. Continuing without running the script."
    # Get previous status from log
    PREV_STATUS=$(get_last_status)
    
    # Always log unhealthy state when script is not found
    log_status "1" "Check script not found or not executable"
    exit 1  # Exit with 1 to indicate unhealthy state when script is not found
fi

# Exit with the same status as the called script
exit $EXIT_STATUS
