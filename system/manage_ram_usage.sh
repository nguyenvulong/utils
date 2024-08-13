#!/bin/bash

# Script to check if the RAM usage is over 90% and kill the highest consuming process

LOG_FILE="/var/log/memmgmt.log"

# Function to log with timestamp
log_with_timestamp() {
    echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

# Threshold for RAM usage
THRESHOLD=90

# Get memory usage excluding cached memory
MEM_DETAILS=$(free -m)
MEM_USAGE=$(awk '/Mem:/ {print (1 - $7/$2) * 100.0}' <<< "$MEM_DETAILS")

# Get the most memory-consuming process details
HIGH_MEM_PROC=$(ps -eo pid,comm,%mem --sort=-%mem | awk 'NR==2')
HIGH_MEM_PID=$(awk '{print $1}' <<< "$HIGH_MEM_PROC")
HIGH_MEM_NAME=$(awk '{print $2}' <<< "$HIGH_MEM_PROC")
HIGH_MEM_PERCENTAGE=$(awk '{print $3}' <<< "$HIGH_MEM_PROC")

# Log current memory usage
log_with_timestamp "Current memory usage: $MEM_USAGE%"

# Compare the current memory usage with the threshold and exclude cache memory
if (( $(echo "$MEM_USAGE > $THRESHOLD" | bc -l) )); then
    log_with_timestamp "Memory usage is above ${THRESHOLD}%. Process to be killed: [PID: $HIGH_MEM_PID, Name: $HIGH_MEM_NAME, Memory%: $HIGH_MEM_PERCENTAGE]"
    kill -9 $HIGH_MEM_PID
    if [ $? -eq 0 ]; then
        log_with_timestamp "Process with PID $HIGH_MEM_PID successfully killed."
    else
        log_with_timestamp "Failed to kill process with PID $HIGH_MEM_PID."
    fi
else
    log_with_timestamp "Memory usage is under the threshold. No action taken."
fi
