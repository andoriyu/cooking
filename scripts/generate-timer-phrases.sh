#!/usr/bin/env sh
set -eu

# Generate timer phrases from Cooklang files
# Usage: generate-timer-phrases [directory]
# Outputs: phrases.json with timer phrases found in .cook files

RECIPE_DIR="${1:-.}"

# Check if directory exists
if [ ! -d "$RECIPE_DIR" ]; then
    echo "Error: Directory '$RECIPE_DIR' does not exist" >&2
    exit 1
fi

# Create temporary file for collecting timer data
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT INT TERM

echo "Scanning for timer phrases in $RECIPE_DIR..." >&2

# Find all .cook files and extract timer phrases
find "$RECIPE_DIR" -name "*.cook" -type f | while read -r cook_file; do
    # Use cook to parse the file and extract timers
    # If cook command fails, fall back to regex parsing
    if command -v cook >/dev/null 2>&1; then
        # Try to use cook-cli to get structured data
        cook recipe read "$cook_file" 2>/dev/null | grep -o '~[^}]*}' || true
    else
        # Fallback: extract timers using grep and sed
        grep -o '~[^.]*{[^}]*}' "$cook_file" 2>/dev/null || true
    fi
done | while read -r timer_line; do
    # Extract timer name and duration from formats like:
    # ~cook hash{10%minutes}
    # ~{4-6%minutes}
    # ~sear side{4%minutes}
    
    # Clean up the timer line - remove any trailing punctuation or extra characters
    clean_timer=$(echo "$timer_line" | sed 's/[.,:;)]*$//' | sed 's/.*\(~[^}]*}\).*/\1/')
    
    if echo "$clean_timer" | grep -q '^~.*{.*}$'; then
        # Extract the full timer phrase (remove the ~)
        timer_phrase=$(echo "$clean_timer" | sed 's/^~//')
        
        # Extract name (everything before the {, clean up spaces)
        timer_name=$(echo "$timer_phrase" | sed 's/{.*$//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | tr ' ' '_')
        
        # Extract duration (everything between { and })
        timer_duration=$(echo "$timer_phrase" | grep -o '{[^}]*}' | tr -d '{}')
        
        # Skip empty names or durations
        if [ -n "$timer_duration" ]; then
            # Create a JSON entry with proper escaping
            if [ -z "$timer_name" ]; then
                timer_name="timer"
            fi
            
            # Escape quotes and backslashes for JSON
            escaped_name=$(echo "$timer_name" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
            escaped_duration=$(echo "$timer_duration" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
            escaped_phrase=$(echo "$timer_phrase" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
            
            echo "{\"name\":\"$escaped_name\",\"duration\":\"$escaped_duration\",\"phrase\":\"$escaped_phrase\"}"
        fi
    fi
done | sort -u > "$TEMP_FILE"

# Convert to final JSON format
echo "Generating phrases.json..." >&2

if [ -s "$TEMP_FILE" ]; then
    # Create JSON object with timer phrases
    echo '{' > phrases.json
    echo '  "timer_phrases": [' >> phrases.json
    
    # Add each timer phrase
    total_lines=$(wc -l < "$TEMP_FILE")
    line_num=0
    
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        echo -n "    $line" >> phrases.json
        if [ "$line_num" -lt "$total_lines" ]; then
            echo ',' >> phrases.json
        else
            echo '' >> phrases.json
        fi
    done < "$TEMP_FILE"
    
    echo '  ],' >> phrases.json
    echo "  \"count\": $total_lines" >> phrases.json
    echo '}' >> phrases.json
    
    echo "Generated phrases.json with $total_lines timer phrases" >&2
else
    # Create empty phrases.json if no timers found
    echo '{"timer_phrases": [], "count": 0}' > phrases.json
    echo "No timer phrases found. Created empty phrases.json" >&2
fi