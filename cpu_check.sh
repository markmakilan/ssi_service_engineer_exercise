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

# CPU usage
TOTAL_CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | \sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \awk '{print 100 - $1"%"}')

EXIT_CODE=0

# Exit code based on the cpu usage
if [ "$TOTAL_CPU_USAGE" >= "$CRITICAL" ]; then
    EXIT_CODE=2
elif [ "$TOTAL_CPU_USAGE" >= "$WARNING" ]; then
    EXIT_CODE=1
fi

# CPU usage information
echo "$(datetime) Info: CPU usage: $TOTAL_CPU_USAGE%"

exit_with_info $EXIT_CODE
