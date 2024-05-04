#!/bin/sh

if [ command -v nvidia-smi &> /dev/null ]; then
    exit 1
fi

nvidia-smi -lms 1000 --query-gpu=utilization.gpu --format=csv,noheader,nounits | while read -r line; do
    echo "percent|int|$line"
    echo ""
done
