#!/bin/bash

# Get memory usage percentage
percent=$(free | grep '^Mem' | awk '{printf "%.0f", $3/$2 * 100.0}')

echo "{\"percent\": $percent}"
