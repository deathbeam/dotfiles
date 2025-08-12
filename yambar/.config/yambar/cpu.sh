#!/bin/sh

cpu_usage=$(top -bn2 | grep "Cpu(s)" | tail -n1 | awk '{print 100 - $8}' | cut -d. -f1)
cpu_temp=$(sensors | awk '/Package id 0:/ {print int($4)}' | tr -d '+°C')

echo "utilization|int|$cpu_usage"
echo "temperature|int|$cpu_temp"
echo ""
