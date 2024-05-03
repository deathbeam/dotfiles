#!/bin/sh

utilization=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{ print ""$1""}')

echo "percent|int|$utilization"
echo ""

