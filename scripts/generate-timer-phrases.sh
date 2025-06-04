#!/usr/bin/env bash
# Generate timer phrases from Cooklang recipe files
# 
# This script processes .cook and .cooklang files to extract timer information
# and generates a JSON file with timer phrases for cooking applications.
#
# Usage: generate-timer-phrases.sh [RECIPES_DIR]
#   RECIPES_DIR: Directory to search for recipe files (default: current directory)
#
# Output: phrases.json - JSON object mapping timer keys to phrases
#
# Dependencies: cook-cli, jq

set -euo pipefail

# Configuration
readonly RECIPES_DIR="${1:-.}"
readonly OUT_FILE="phrases.json"

# Validate dependencies
if ! command -v cook >/dev/null 2>&1; then
    echo "Error: cook-cli is required but not installed" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required but not installed" >&2
    exit 1
fi

# Validate input directory
if [[ ! -d "$RECIPES_DIR" ]]; then
    echo "Error: Directory '$RECIPES_DIR' does not exist" >&2
    exit 1
fi

# Initialize output file
: > "$OUT_FILE"

# Process recipe files
find "$RECIPES_DIR" -type f \( -name '*.cook' -o -name '*.cooklang' \) | \
while IFS= read -r file; do
    echo "Processing: $file"
    
    # Extract timer information and generate phrases
    if ! cook recipe -f json "$file" | \
    jq -c '
        # For each timer (or empty if none)
        (.timers // [])[]
        |
        # Compute raw duration:
        ( if .quantity.value.type == "text" then
            (.quantity.value.value | split("-")[0])
          else
            (.quantity.value.value.value) as $n
            | if ($n|floor)==$n then ($n|floor|tostring) else ($n|tostring) end
          end
        ) as $dur
        |
        # Grab unit and (optional) name
        .quantity.unit as $unit
        | (.name // "") as $name
        |
        # Build the key: name|dur|unit
        ($name + "|" + $dur + "|" + $unit) as $key
        |
        # Build the phrase
        ( if $name != "" then
            "Chef, your " + $name + " timer is done."
          else
            "Chef, your " + $dur + " " + $unit + " timer is done."
          end
        ) as $phrase
        |
        { ($key): $phrase }
    '; then
        echo "Warning: Failed to process $file" >&2
    fi
done | jq -s 'add' > "$OUT_FILE"

# Validate output and print summary
if [[ -f "$OUT_FILE" ]]; then
    count=$(jq 'keys | length' "$OUT_FILE" 2>/dev/null || echo "0")
    echo "Generated $count timer phrases in $OUT_FILE"
else
    echo "Error: Failed to generate $OUT_FILE" >&2
    exit 1
fi