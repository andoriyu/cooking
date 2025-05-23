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

usage() {
  cat <<EOF >&2
Usage: $0 [-f] [-n N] [-u] [-h]

Options:
  -f       Force overwrite of existing files.
  -n N     Limit to the first N entries (for testing).
  -u       Pull latest Bark flake (nix --refresh).
  -h       Show this help message.
EOF
  exit 1
}

# Parse options
while getopts "fn:uh" opt; do
  case "$opt" in
    f) FORCE=1 ;;
    n) LIMIT=$OPTARG ;;
    u) REFRESH=1 ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

mkdir -p "$OUT_DIR"
count=0

# Iterate over key\tphrase pairs from JSON
jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$PHRASES_FILE" | \
while IFS=$'\t' read -r key phrase; do
  # Enforce limit
  if [ "$LIMIT" -gt 0 ] && [ "$count" -ge "$LIMIT" ]; then
    break
  fi

  # Build filename slug: replace '|' with '_'
  slug=$(printf "%s" "$key" | tr '|' '_')
  out="$OUT_DIR/${slug}.wav"

  # Skip or overwrite
  if [ -f "$out" ]; then
    if [ "$FORCE" -eq 1 ]; then
      echo "[rm]   Overwriting $out"
      rm -f "$out"
    else
      echo "[skip] $out exists"
      count=$((count + 1))
      continue
    fi
  fi

  echo "[gen] $key → $out"
  # Run Bark via Nix
  nix run ${REFRESH:+--refresh} github:andoriyu/flakes#bark -- \
    --text="$phrase" \
    --output_filename="$out"

  count=$((count + 1))
done

echo "Done: generated $count files in $OUT_DIR"