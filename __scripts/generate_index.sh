#!/usr/bin/env bash
# Script to generate an index file for timer audio files

# Set shell options to fail on error
set -eo pipefail

# Check if required arguments are provided
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <phrases_json> <audio_dir> <index_json>"
  exit 1
fi

PHRASES_JSON="$1"
AUDIO_DIR="$2"
INDEX_JSON="$3"

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$INDEX_JSON")"

# Create an index file with paths relative to repo root
jq -r 'to_entries[] | .key + "\t" + "'"$AUDIO_DIR"'/" + (.key | gsub("\\|"; "_")) + ".m4a"' "$PHRASES_JSON" | \
jq -R 'split("\t") | {key: .[0], path: .[1]}' | \
jq -s '{timers: .}' > "$INDEX_JSON"

echo "Generated index file at $INDEX_JSON"
