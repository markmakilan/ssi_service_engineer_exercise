#!/bin/bash

criticalThreshold=""
warningThreshold=""
emailAddress=""

while getopts "c:w:e:" opt; do
    case $opt in
        c) criticalThreshold=$OPTARG ;;
        w) warningThreshold=$OPTARG ;;
        e) emailAddress=$OPTARG ;;
        *) exit 1 ;;
    esac
done

if [ -z "$criticalThreshold" ] || [ -z "$warningThreshold" ] || [ -z "$emailAddress" ]; then
    exit 1
fi

if (( criticalThreshold <= warningThreshold )); then
    echo "Critical threshold must be greater than warning threshold."
    exit 1
fi

totalMemory=$(free | grep Mem: | awk '{ print $2 }')
usedMemory=$(free | grep Mem: | awk '{ print $3 }')

memoryUsagePecentage=$(( usedMemory * 100 / totalMemory ))

if (( memoryUsagePecentage >= criticalThreshold )); then
    code=2
elif (( memoryUsagePecentage >= warningThreshold )); then
    code=1
else
    code=0
fi

echo "Memory usage: $MEMORY_USAGE_PERCENT%"

exit $code