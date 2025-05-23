#!/usr/bin/env sh
# convert-wav-to-m4a.sh  —  Transcode every *.wav under $DIR (default timer-audio)
#                          to AAC-LC in an .m4a container, next to the source file.

set -eu  # stop on error / undefined var

DIR=${1:-timer-audio}

# Abort early if the directory doesn't exist
[ -d "$DIR" ] || { echo "Directory not found: $DIR" >&2; exit 1; }

for SRC in "$DIR"/*.wav; do
    # If the glob doesn't match, it expands to the pattern itself;
    # guard against that corner case:
    [ -e "$SRC" ] || { echo "No .wav files found in $DIR"; break; }

    BASE=${SRC%.*}         # strip final extension
    DST="${BASE}.m4a"

    if [ -f "$DST" ]; then
        printf '• Skipping (exists): %s\n' "$DST"
        continue
    fi

    printf '• Converting: %s → %s\n' "$SRC" "$DST"

    ffmpeg -hide_banner -loglevel error -y \
           -i "$SRC" \
           -c:a aac \
           -b:a 128k \
           -movflags +faststart \
           "$DST"
done