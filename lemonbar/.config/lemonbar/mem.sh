#!/bin/sh

free | awk '/Mem/ {printf("%.0f", $3/$2*100)}'
