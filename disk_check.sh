#!/bin/bash

# Initial value
CRITICAL="90"
WARNING="80"
EMAIL=""

# Get current time
datetime() {
    echo $(date +"%Y-%m-%d %H:%M:%S")
}

# Show needed parameters 
usage() {
    echo "$(datetime) Usage: $0 -c <critical threshold> -w <warning threshold> -e <email>"
    exit_with_info 1
}

# Show exit code message
exit_with_info() {
    case $1 in
        0) echo "$(datetime) Info: Exiting with success (exit code $1)." ;;
        1) echo "$(datetime) Info: Exiting with warning (exit code $1)." ;;
        2) echo "$(datetime) Info: Exiting with critical error (exit code $1)." ;;
        *) echo "$(datetime) Info: Exiting with unknown error." ;;
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
    echo "$(datetime) Error: The critical threshold must be greater than warning threshold."
    usage
fi

# Disk usage
# DISK_PARTITION=$(df -P | awk '0+$5 >= $thresholds {print}')
DISK_PARTITION=$(df -h | awk '{ print $5 }' | grep -v Use | head -n 1 | sed 's/%//')

EXIT_CODE=0

# Exit code based on the disk usage
if [ "$DISK_PARTITION" >= "$CRITICAL" ]; then
    EXIT_CODE=2
elif [ "$DISK_PARTITION" >= "$WARNING" ]; then
    EXIT_CODE=1
fi

# Disk usage information
echo "Info: Disk usage: $DISK_PARTITION%"

exit_with_info $EXIT_CODE
