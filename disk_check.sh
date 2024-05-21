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
        0) echo "$(datetime) Info: Exit code $1" ;;
        1) echo "$(datetime) Info: Exit code $1" ;;
        2) echo "$(datetime) Info: Exit code $1" ;;
        *) echo "$(datetime) Info: Unknown error." ;;
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
if [ "$DISK_PARTITION" -ge "$CRITICAL" ]; then
    SUBJECT="$(datetime) disk_check - critical"
    
    echo -e "Partition of the Disk:\n\n$(lsblk)" | mailx -s "$SUBJECT" $EMAIL

    EXIT_CODE=2
elif [ "$DISK_PARTITION" -ge "$WARNING" ]; then
    EXIT_CODE=1
fi

# Disk usage information
echo "$(datetime) Info: Disk usage: $DISK_PARTITION%"

exit_with_info $EXIT_CODE
