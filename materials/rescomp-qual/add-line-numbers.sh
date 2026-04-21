#!/usr/bin/env bash
# This script adds line numbers to an aggregated transcription file.

input="$1"

awk '{
    printf("(%03d)\t%s\n", NR, $0)
}' "$input"
