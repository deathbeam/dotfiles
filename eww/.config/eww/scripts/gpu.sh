#!/bin/sh

if [ command -v nvidia-smi &> /dev/null ]; then
    echo "utilization|int|-1"
    echo "temperature|int|-1"
    exit 1
fi

nvidia-smi -lms 1000 --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | while read -r line; do
    utilization=$(echo "$line" | cut -d ',' -f 1 | tr -d ' ')
    temperature=$(echo "$line" | cut -d ',' -f 2 | tr -d ' ')
    echo "utilization|int|$utilization"
    echo "temperature|int|$temperature"
    echo ""
done
