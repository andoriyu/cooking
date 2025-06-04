#!/usr/bin/env bash
# Script to generate audio files from timer phrases

# Set shell options to fail on error
set -eo pipefail

# Check if required arguments are provided
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <phrases_json> <output_dir> [force_regenerate]"
  exit 1
fi

PHRASES_JSON="$1"
OUTPUT_DIR="$2"
FORCE_REGENERATE="${3:-false}"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate audio files for each phrase
jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$PHRASES_JSON" | \
while IFS=$'\t' read -r key phrase; do
  # Build filename slug: replace '|' with '_'
  slug=$(printf "%s" "$key" | tr '|' '_')
  out="${OUTPUT_DIR}/${slug}.m4a"
  
  # Skip if file already exists and not forcing regeneration
  if [ -f "$out" ] && [ "$FORCE_REGENERATE" != "true" ]; then
    echo "Skipping existing file: $out"
    continue
  fi
  
  echo "Generating audio for: $phrase"
  
  # Generate WAV using Bark
  bark --text="$phrase" --output_filename="temp.wav"
  
  # Convert to M4A using ffmpeg
  ffmpeg -hide_banner -loglevel error -y \
    -i "temp.wav" \
    -c:a aac \
    -b:a 128k \
    -movflags +faststart \
    "$out"
  
  # Clean up temporary WAV file
  rm -f temp.wav
done

echo "Audio generation complete"
