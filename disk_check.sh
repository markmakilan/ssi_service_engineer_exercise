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

# Disk usage
# DISK_PARTITION=$(df -P | awk '0+$5 >= $thresholds {print}')
DISK_PARTITION=$(df -h | awk '{ print $5 }' | grep -v Use | head -n 1 | sed 's/%//')

EXIT_CODE=0

# Exit code based on the disk usage
if [ "$DISK_PARTITION" >= "$CRITICAL_THRESHOLD" ]; then
    EXIT_CODE=2
elif [ "$DISK_PARTITION" >= "$WARNING_THRESHOLD" ]; then
    EXIT_CODE=1
fi

# Disk usage information
echo "Info: Disk usage: $DISK_PARTITION%"

exit_with_info $EXIT_CODE
