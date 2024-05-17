#!/bin/bash

# Initial value
CRITICAL="90"
WARNING="80"
EMAIL=""

# Get current time
datetime() {
    return $(date +"%Y-%m-%d %H:%M:%S")
}

# Show needed parameters 
usage() {
    echo "Usage: $0 -c <critical threshold> -w <warning threshold> -e <email>"
    exit_with_info 1
}

# Show exit code message
exit_with_info() {
    case $1 in
        0) echo "${ datetime } Info: Exiting with success (exit code $1)." ;;
        1) echo "${ datetime } Info: Exiting with warning (exit code $1)." ;;
        2) echo "${ datetime } Info: Exiting with critical error (exit code $1)." ;;
        *) echo "${ datetime } Info: Exiting with unknown error." ;;
    esac

    exit $1
}


# Get arguments
while getopts "c:w:e:" opt; do

    if [ "$OPTARG" != "" ]; then

        case $opt in
            c) 
                CRITICAL=$OPTARG ;;
            w) 
                WARNING=$OPTARG ;;
            e) 
                EMAIL=$OPTARG ;;
            *) 
                usage ;;
        esac
    else
        usage
    fi
done

# Validate critical threshold and warning threshold
# critical threshold must be greater than warning threshold
if (( CRITICAL <= WARNING )); then
    echo "Error: The critical threshold must be greater than warning threshold."
    usage
fi

# Memory usage information
TOTAL_MEMORY=$(free|grep Mem:|awk '{ print $2 }')
USED_MEMORY=$(free|grep Mem:|awk '{ print $3 }')

# Computed memory usage
TOTAL_MEMORY_USAGE=$((USED_MEMORY * 100 / TOTAL_MEMORY ))

EXIT_CODE=0

# Exit code based on the memory usage
if ((TOTAL_MEMORY_USAGE >= CRITICAL)); then 
    EXIT_CODE=2
elif ((TOTAL_MEMORY_USAGE >= WARNING)); then 
    EXIT_CODE=1
fi

# Print memory usage information
echo "Info: Memory usage: $TOTAL_MEMORY_USAGE%"

exit_with_info $EXIT_CODE
