#!/usr/bin/env bash
# Script to extract timer phrases from recipe files

# Set shell options to fail on error
set -eo pipefail

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$2")"

# Extract phrases using cook (from cook-cli package)
cook recipe -f json "$1" | \
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
' | jq -s 'add' > "$2"

echo "Extracted timer phrases to $2"
