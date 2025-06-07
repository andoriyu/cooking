#!/bin/sh
# Generate audio files for timer phrases using Bark TTS from andoriyu/flakes
#
# This script reads timer phrases from a JSON file and generates
# m4a audio files using Bark text-to-speech from andoriyu/flakes,
# then converts the WAV output to M4A using ffmpeg.
#
# Usage: generate-timer-audio.sh [PHRASES_FILE] [VOICE]
#   PHRASES_FILE: JSON file with timer phrases (default: phrases.json)
#   VOICE: Optional voice to use (default: v2/en_speaker_6)
#
# Dependencies: jq, nix, ffmpeg

set -e

# Configuration
PHRASES_FILE="${1:-phrases.json}"
VOICE="${2:-v2/en_speaker_6}"
OUTPUT_DIR="audio"
TEMP_DIR="$(mktemp -d)"

# Cleanup temporary directory on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# Validate dependencies
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required but not installed" >&2
    exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
    echo "Error: nix is required but not installed" >&2
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg is required but not installed" >&2
    exit 1
fi

# Validate input file
if [ ! -f "$PHRASES_FILE" ]; then
    echo "Error: File '$PHRASES_FILE' does not exist" >&2
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Process each phrase
jq -r 'to_entries | .[] | [.key, .value] | @tsv' "$PHRASES_FILE" | while IFS=$'\t' read -r key phrase; do
    # Sanitize filename
    filename=$(echo "$key" | tr '|/ ' '_')
    output_file="$OUTPUT_DIR/${filename}.m4a"
    temp_wav_file="$TEMP_DIR/${filename}.wav"
    
    # Skip if file already exists
    if [ -f "$output_file" ]; then
        echo "Skipping existing file: $output_file"
        continue
    fi
    
    echo "Generating audio for: $phrase"
    
    # Generate audio using bark from andoriyu/flakes
    if ! nix run github:andoriyu/flakes#bark -- --text "$phrase" --output "$temp_wav_file" --voice "$VOICE"; then
        echo "Error generating audio for: $phrase" >&2
        continue
    fi
    
    echo "Converting WAV to M4A..."
    if ! ffmpeg -i "$temp_wav_file" -c:a aac -b:a 128k -y "$output_file" -loglevel error; then
        echo "Error converting WAV to M4A for: $phrase" >&2
        continue
    fi
    
    echo "Successfully generated: $output_file"
done

# Count generated files
file_count=$(find "$OUTPUT_DIR" -name "*.m4a" | wc -l)
echo "Generated $file_count audio files in $OUTPUT_DIR"
