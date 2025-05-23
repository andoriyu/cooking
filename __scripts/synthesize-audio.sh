#!/usr/bin/env sh
set -eu

# JSON file mapping keys (name|dur|unit) to phrases
PHRASES_FILE="phrases.json"
# Output directory for audio files
OUT_DIR="timer-audio"

# Flags
FORCE=0      # overwrite existing files
LIMIT=0      # max number of files to generate
REFRESH=0    # nix --refresh input
KEEP_WAV=0   # keep intermediate WAV files

usage() {
  cat <<EOF >&2
Usage: $0 [-f] [-n N] [-u] [-k] [-h]

Options:
  -f       Force overwrite of existing files.
  -n N     Limit to the first N entries (for testing).
  -u       Pull latest Bark flake (nix --refresh).
  -k       Keep intermediate WAV files.
  -h       Show this help message.
EOF
  exit 1
}

# Parse options
while getopts "fn:ukh" opt; do
  case "$opt" in
    f) FORCE=1 ;;
    n) LIMIT=$OPTARG ;;
    u) REFRESH=1 ;;
    k) KEEP_WAV=1 ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

mkdir -p "$OUT_DIR"
count=0

# Check if the JSON file has content
if [ ! -s "$PHRASES_FILE" ] || [ "$(jq 'length' "$PHRASES_FILE")" = "0" ]; then
  echo "No phrases found in $PHRASES_FILE, skipping audio generation"
  exit 0
fi

# Iterate over key\tphrase pairs from JSON
jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$PHRASES_FILE" | \
while IFS=$'\t' read -r key phrase; do
  # Enforce limit
  if [ "$LIMIT" -gt 0 ] && [ "$count" -ge "$LIMIT" ]; then
    break
  fi

  # Build filename slug: replace '|' with '_'
  slug=$(printf "%s" "$key" | tr '|' '_')
  wav_file="$OUT_DIR/${slug}.wav"
  m4a_file="$OUT_DIR/${slug}.m4a"

  # Skip if M4A file already exists and not forcing overwrite
  if [ -f "$m4a_file" ] && [ "$FORCE" -eq 0 ]; then
    echo "[skip] $m4a_file exists"
    count=$((count + 1))
    continue
  fi

  # Remove existing files if forcing overwrite
  if [ "$FORCE" -eq 1 ]; then
    [ -f "$wav_file" ] && echo "[rm]   Removing $wav_file" && rm -f "$wav_file"
    [ -f "$m4a_file" ] && echo "[rm]   Removing $m4a_file" && rm -f "$m4a_file"
  fi

  echo "[gen] $key → $wav_file"
  # Run Bark via Nix to generate WAV file
  nix run ${REFRESH:+--refresh} github:andoriyu/flakes#bark -- \
    --text="$phrase" \
    --output_filename="$wav_file"

  # Convert WAV to M4A
  echo "[conv] $wav_file → $m4a_file"
  nix run nixpkgs#ffmpeg -- -hide_banner -loglevel error -y \
    -i "$wav_file" \
    -c:a aac \
    -b:a 128k \
    -movflags +faststart \
    "$m4a_file"

  # Remove WAV file if not keeping intermediates
  if [ "$KEEP_WAV" -eq 0 ] && [ -f "$m4a_file" ]; then
    echo "[rm]   Removing intermediate $wav_file"
    rm -f "$wav_file"
  fi

  count=$((count + 1))
done

echo "Done: generated $count audio files in $OUT_DIR"