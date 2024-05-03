#!/bin/sh

if ! command -v nvidia-smi > /dev/null; then
    exit 1
fi

nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{ print ""$1""}'
