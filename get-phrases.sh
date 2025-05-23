#!/usr/bin/env sh
set -eu

RECIPES_DIR="${1:-.}" # Use first argument for directory, or default to current working directory
OUT_FILE="phrases.json"

# Start with empty JSON
: > "$OUT_FILE"

find "$RECIPES_DIR" -type f \( -name '*.cook' -o -name '*.cooklang' \) | \
while IFS= read -r file; do
  cook recipe -f json "$file" | \
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
  '
done | jq -s 'add' > "$OUT_FILE"

# Print summary
count=$(jq 'keys | length' "$OUT_FILE")
echo "Wrote $count entries to $OUT_FILE"