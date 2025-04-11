#!/usr/bin/env zsh

# Use current directory if none provided
input_directory="${1:-.}"
if ! cd "$input_directory" 2>/dev/null; then
    echo "Error: Cannot access directory: $input_directory"
    return 1  # Use return instead of exit for aliases/functions
fi

# Process .mov files
setopt NULL_GLOB
mov_files=(*.mov)
if [[ ${#mov_files[@]} -eq 0 ]]; then
    echo "No .mov files found in $input_directory"
    return 0  # Success but nothing to do
fi

# Now process files
for mov_file in $mov_files; do
    if [[ -f "$mov_file" ]]; then
        mp4_file="${mov_file%.mov}.mp4"
        echo "Converting: $mov_file → $mp4_file"
        if ffmpeg -i "$mov_file" -c:v libx264 -crf 23 -c:a aac "$mp4_file" >/dev/null 2>&1; then
            if rm "$mov_file"; then
                echo "Success: $mov_file converted and removed"
            else
                echo "Warning: $mov_file converted but could not be deleted"
            fi
        else
            echo "Error: Failed to convert $mov_file"
        fi
    fi
done