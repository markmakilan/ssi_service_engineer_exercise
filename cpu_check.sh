#!/bin/bash

# Initial value
CRITICAL_THRESHOLD="90"
WARNING_THRESHOLD="80"
EMAIL_ADDRESS=""

EXIT_CODE=0

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

# CPU usage
TOTAL_CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | \sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \awk '{print 100 - $1"%"}')

# Exit code based on the cpu usage
if [ "$TOTAL_CPU_USAGE" >= "$CRITICAL_THRESHOLD" ]; then
    EXIT_CODE=2
elif [ "$TOTAL_CPU_USAGE" >= "$WARNING_THRESHOLD" ]; then
    EXIT_CODE=1
else
    EXIT_CODE=0
fi

# CPU usage information
echo "Info: CPU usage: $TOTAL_CPU_USAGE"

exit_with_info $EXIT_CODE
