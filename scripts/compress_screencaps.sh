#!/bin/bash

set -e

# Use current directory if none provided
input_directory="${1:-.}"
cd "$input_directory" || {
    echo "Error: Cannot access directory: $input_directory"
    exit 1
}

# Process .mov files
shopt -s nullglob  # Avoid looping if no .mov files exist
for mov_file in *.mov; do
    if [ -f "$mov_file" ]; then
        mp4_file="${mov_file%.mov}.mp4"
        echo "Converting: $mov_file → $mp4_file"
        ffmpeg -i "$mov_file" -c:v libx264 -crf 23 -c:a aac "$mp4_file" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            rm "$mov_file" || echo "Warning: Failed to delete $mov_file"
            echo "Success: $mov_file converted and removed"
        else
            echo "Error: Failed to convert $mov_file"
        fi
    fi
done