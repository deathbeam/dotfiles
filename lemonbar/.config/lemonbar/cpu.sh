#!/bin/sh

# Get the first line with aggregate of all CPUs
cpu_last=($(head -n1 /proc/stat))
idle_last=${cpu_last[4]}

# Sleep for a second
sleep 1

# Get the same line again
cpu_now=($(head -n1 /proc/stat))
idle_now=${cpu_now[4]}

# Calculate the CPU usage
idle_delta=$((idle_now - idle_last))
total_delta=$((cpu_now[1]+cpu_now[2]+cpu_now[3]+cpu_now[4]-cpu_last[1]-cpu_last[2]-cpu_last[3]-cpu_last[4]))

# Calculate the CPU usage percentage
cpu_usage=$((100*( (total_delta) - (idle_delta) ) / (total_delta) ))

echo $cpu_usage
