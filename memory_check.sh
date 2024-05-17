#!/bin/bash

# Initial value
CRITICAL_THRESHOLD="90"
WARNING_THRESHOLD="80"
EMAIL_ADDRESS=""

# Print required parameters
usage() {
    echo "Usage: $0 -c <critical_threshold> -w <warning_threshold> -e <email_address>"
    exit_with_info 1
}

# Print the exit code message
exit_with_info() {
    case $1 in
        0) echo "Info: Exiting with success (exit code $1)." ;;
        1) echo "Info: Exiting with warning (exit code $1)." ;;
        2) echo "Info: Exiting with critical error (exit code $1)." ;;
        *) echo "Info: Exiting with unknown error (exit code $1)." ;;
    esac

    exit $1
}

# Parse arguments
while getopts "c:w:e:" opt; do
    case $opt in
        c) CRITICAL_THRESHOLD=$OPTARG ;;
        w) WARNING_THRESHOLD=$OPTARG ;;
        e) EMAIL_ADDRESS=$OPTARG ;;
        *) usage ;;
    esac
done

# Check all given parameters
if [ -z "$CRITICAL_THRESHOLD" ] || [ -z "$WARNING_THRESHOLD" ] || [ -z "$EMAIL_ADDRESS" ]; then
    usage
fi

# Validate critical threshold and warning threshold
# critical threshold must be greater than warning threshold
if (( CRITICAL_THRESHOLD <= WARNING_THRESHOLD )); then
    echo "Error: Critical threshold must be greater than warning threshold."
    usage
fi

# Memory usage information
TOTAL_MEMORY=$(free | grep Mem: | awk '{ print $2 }')
USED_MEMORY=$(free | grep Mem: | awk '{ print $3 }')

# Computed memory usage
MEMORY_USAGE=$(( USED_MEMORY * 100 / TOTAL_MEMORY ))

EXIT_CODE=0

# Exit code based on the memory usage
if (( MEMORY_USAGE >= CRITICAL_THRESHOLD )); then 
    EXIT_CODE=2
elif (( MEMORY_USAGE >= WARNING_THRESHOLD )); then 
    EXIT_CODE=1
fi

# Print memory usage information
echo "Info: Memory usage: $MEMORY_USAGE%"

exit_with_info $EXIT_CODE
