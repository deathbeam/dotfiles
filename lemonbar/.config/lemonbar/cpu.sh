#!/bin/sh

# File to store the previous CPU info
file="/tmp/cpu_usage"

if [ -f "$file" ]
then
  # Get the previous CPU info
  prev_cpu_info=($(cat "$file"))
  PREV_TOTAL=${prev_cpu_info[0]}
  PREV_IDLE=${prev_cpu_info[1]}
else
  # This is the first time this script is run
  PREV_TOTAL=0
  PREV_IDLE=0
fi

# Get the total CPU statistics, discarding the 'cpu ' prefix.
CPU=($(sed -n 's/^cpu\s//p' /proc/stat))
IDLE=${CPU[3]} # Just the idle CPU time.

# Calculate the total CPU time.
TOTAL=0
for VALUE in "${CPU[@]:0:8}"; do
TOTAL=$((TOTAL+VALUE))
done

# Calculate the CPU usage since we last checked.
DIFF_IDLE=$((IDLE-PREV_IDLE))
DIFF_TOTAL=$((TOTAL-PREV_TOTAL))
DIFF_USAGE=$(((1000*(DIFF_TOTAL-DIFF_IDLE)/DIFF_TOTAL+5)/10))

# Print the CPU usage
echo $DIFF_USAGE

# Store the current CPU info for the next run
echo "$TOTAL $IDLE" > "$file"
