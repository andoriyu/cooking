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
