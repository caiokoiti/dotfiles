#!/bin/bash

set -e

input_directory="$1"
cd "$input_directory" || exit

for mov_file in *.mov; do
   if [ -f "$mov_file" ]; then
       mp4_file="${mov_file%.mov}.mp4"
       ffmpeg -i "$mov_file" -c:v libx264 -crf 23 -c:a aac -strict -2 "$mp4_file"
       
       if [ $? -eq 0 ]; then
           rm "$mov_file"
           echo "Converted: $mov_file → $mp4_file"
       else
           echo "Error converting $mov_file"
       fi
   fi
done