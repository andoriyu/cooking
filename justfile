# Check for broken symlinks in the recipes directory
check-symlinks:
    #!/usr/bin/env bash
    echo "Checking for broken symlinks in recipes directory..."
    broken_links=$(find . -type l -exec test ! -e {} \; -print)
    if [ -n "$broken_links" ]; then
        echo "Found broken symlinks:"
        echo "$broken_links" | sed 's/^/  - /'
        echo ""
        echo "To fix broken symlinks, run: just fix-symlinks"
        exit 1
    else
        echo "No broken symlinks found."
    fi

# Fix broken symlinks in the recipes directory
fix-symlinks:
    #!/usr/bin/env bash
    echo "Fixing broken symlinks in recipes directory..."
    
    # Process each broken symlink
    find . -type l -exec test ! -e {} \; -print | while read -r symlink; do
        echo "Processing broken symlink: $symlink"
        
        # Get the base name of the target file
        base_name=$(basename "$symlink")
        
        # Find the actual file in the repository
        actual_file=$(find . -name "$base_name" -type f | head -1)
        
        if [ -n "$actual_file" ]; then
            # Get the directory of the symlink
            symlink_dir=$(dirname "$symlink")
            
            # Create a relative path from symlink to target
            cd "$symlink_dir" || exit 1
            rel_path=$(echo "../../$(echo "$actual_file" | sed 's|^\./||')")
            cd - > /dev/null || exit 1
            
            # Fix the symlink
            echo "  Fixing: $symlink -> $rel_path"
            rm "$symlink"
            ln -s "$rel_path" "$symlink"
        else
            echo "  Could not find target file for: $symlink"
        fi
    done
    
    echo "Done fixing symlinks."

# Validate frontmatter in all recipe files
validate-frontmatter:
    #!/bin/sh
    set -eu
    
    echo "Validating frontmatter in recipe files..."
    
    # Check if grit is installed
    if ! command -v grit >/dev/null 2>&1; then
        echo "Error: grit is not installed. Please install it first."
        exit 1
    fi
    
    # Create a temporary directory for extracted frontmatter
    TEMP_DIR=$(mktemp -d)
    # Ensure temp directory is removed on exit
    trap 'rm -rf "${TEMP_DIR:?}"' EXIT INT TERM
    
    # Find all .cook files
    EXIT_CODE=0
    
    find . -name "*.cook" -type f | while read -r file; do
        printf "Checking %s...\n" "$file"
        
        # Extract frontmatter from the .cook file (between first two --- markers)
        FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d')
        
        if [ -z "$FRONTMATTER" ]; then
            printf "  Error: No frontmatter found in %s\n" "$file"
            EXIT_CODE=1
            continue
        fi
        
        # Create a temporary file with the extracted frontmatter
        TEMP_FILE="${TEMP_DIR}/$(basename "$file" .cook).yaml"
        printf "%s\n" "$FRONTMATTER" > "$TEMP_FILE"
        
        # Validate the frontmatter using gritql
        if ! grit apply .grit/frontmatter-schema.grit "$TEMP_FILE" >/dev/null 2>&1; then
            printf "  Error: Invalid frontmatter in %s\n" "$file"
            # Run again with verbose output to show the specific issues
            grit apply .grit/frontmatter-schema.grit "$TEMP_FILE" || true
            EXIT_CODE=1
        fi
    done
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "All frontmatter validated successfully!"
    else
        echo "Frontmatter validation failed for some files."
    fi
    
    exit $EXIT_CODE

# Validate frontmatter for a single recipe
# Usage: just validate-recipe ./path/to/recipe.cook [--print]
validate-recipe recipe *args="":
    #!/bin/sh
    set -eu
    
    # Check if --print flag is provided
    PRINT_FRONTMATTER=0
    for arg in {{args}}; do
        if [ "$arg" = "--print" ]; then
            PRINT_FRONTMATTER=1
        fi
    done
    
    echo "Validating frontmatter for {{recipe}}..."
    
    # Check if grit is installed
    if ! command -v grit >/dev/null 2>&1; then
        echo "Error: grit is not installed. Please install it first."
        exit 1
    fi
    
    # Check if the recipe file exists
    if [ ! -f "{{recipe}}" ]; then
        echo "Error: Recipe file '{{recipe}}' not found."
        exit 1
    fi
    
    # Create a temporary directory for extracted frontmatter
    TEMP_DIR=$(mktemp -d)
    # Ensure temp directory is removed on exit
    trap 'rm -rf "${TEMP_DIR:?}"' EXIT INT TERM
    
    # Extract frontmatter from the .cook file (between first two --- markers)
    FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "{{recipe}}" | sed '1d;$d')
    
    if [ -z "$FRONTMATTER" ]; then
        echo "Error: No frontmatter found in {{recipe}}"
        exit 1
    fi
    
    # Print frontmatter if requested
    if [ "$PRINT_FRONTMATTER" -eq 1 ]; then
        echo ""
        echo "Extracted frontmatter:"
        echo "--------------------"
        echo "$FRONTMATTER"
        echo "--------------------"
        echo ""
    fi
    
    # Create a temporary file with the extracted frontmatter
    TEMP_FILE="${TEMP_DIR}/$(basename "{{recipe}}" .cook).yaml"
    printf "%s\n" "$FRONTMATTER" > "$TEMP_FILE"
    
    # Validate the frontmatter using gritql
    if ! grit apply .grit/frontmatter-schema.grit "$TEMP_FILE"; then
        echo "Error: Invalid frontmatter in {{recipe}}"
        exit 1
    else
        echo "Frontmatter validation successful for {{recipe}}!"
    fi
