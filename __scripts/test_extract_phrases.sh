#!/usr/bin/env bash
# Script to test the extraction of timer phrases

# Set shell options to fail on error
set -eo pipefail

# Find a recipe file with timers
RECIPE_FILE=$(find . -name "*.cook" -exec grep -l "~" {} \; | head -1)

if [ -z "$RECIPE_FILE" ]; then
  echo "Error: No recipe files with timers found"
  exit 1
fi

echo "Testing with recipe file: $RECIPE_FILE"

# Create a temporary output file
TEMP_OUTPUT="/tmp/test_phrases.json"

# Run the extraction script
bash __scripts/extract_timer_phrases.sh "$RECIPE_FILE" "$TEMP_OUTPUT"

# Check if the output file was created
if [ ! -f "$TEMP_OUTPUT" ]; then
  echo "Error: Output file was not created"
  exit 1
fi

# Check if the output file contains valid JSON
if ! jq empty "$TEMP_OUTPUT" 2>/dev/null; then
  echo "Error: Output file does not contain valid JSON"
  exit 1
fi

# Check if any timer phrases were extracted
TIMER_COUNT=$(jq 'length' "$TEMP_OUTPUT")
if [ "$TIMER_COUNT" -eq 0 ]; then
  echo "Warning: No timer phrases were extracted"
else
  echo "Success: Extracted $TIMER_COUNT timer phrases"
  echo "Phrases:"
  jq -r 'to_entries[] | "- \(.key): \(.value)"' "$TEMP_OUTPUT"
fi

# Clean up
rm -f "$TEMP_OUTPUT"

echo "Test completed successfully"
