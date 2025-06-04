#!/bin/sh
set -eu

# Pre-commit hook wrapper for frontmatter validation
# Only validates .cook files that are staged for commit

# Get list of staged .cook files
staged_files=""
git diff --cached --name-only | while read -r file; do
    case "$file" in
        *.cook)
            staged_files="$staged_files $file"
            ;;
    esac
done

# Create a temporary file to store the list of staged .cook files
temp_file=$(mktemp)
git diff --cached --name-only | grep '\.cook$' > "$temp_file" || true

# Check if any .cook files are staged
if [ ! -s "$temp_file" ]; then
    echo "No .cook files staged for commit"
    rm -f "$temp_file"
    exit 0
fi

# Count staged files
file_count=$(wc -l < "$temp_file")

# Run validation on staged files
echo "Running frontmatter validation on $file_count staged .cook file(s)..."

# Read files from temp file and pass to validation script
# shellcheck disable=SC2046
"$(dirname "$0")/validate-frontmatter.sh" $(cat "$temp_file")
exit_code=$?

# Clean up
rm -f "$temp_file"
exit $exit_code