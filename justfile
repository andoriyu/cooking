# Extract and list all unique image domains used in recipes
list-image-domains:
    #!/bin/sh
    set -eu
    
    echo "Extracting unique image domains from recipe files..."
    
    # Create a temporary file to store domains
    TEMP_FILE=$(mktemp)
    # Ensure temp file is removed on exit
    trap 'rm -f "${TEMP_FILE:?}"' EXIT INT TERM
    
    # Find all .cook files with image URLs
    find . -name "*.cook" -type f | while read -r file; do
        # Extract the image URL from the file
        image_url=$(grep "^image:" "$file" | sed 's/^image:[[:space:]]*//')
        
        # Skip if no image URL found
        [ -z "$image_url" ] && continue
        
        # Extract domain: first remove https://, then keep only content before first /
        domain=$(echo "$image_url" | sed -e 's|https://||' | sed -e 's|/.*||')
        
        # Store domain and filename for reference
        printf "%s\t%s\n" "$domain" "$(basename "$file")" >> "$TEMP_FILE"
    done
    
    # Check if we found any domains
    if [ ! -s "$TEMP_FILE" ]; then
        echo "No image domains found in recipe files."
        exit 0
    fi
    
    # Sort domains, count occurrences, and format output
    echo ""
    echo "Domain                          Count  Example Recipe"
    echo "------------------------------  -----  --------------"
    
    # Process the collected data
    sort "$TEMP_FILE" | 
    awk '{ 
        domain = $1;
        file = $2;
        
        # Count domains
        count[domain]++;
        
        # Store first example file for each domain
        if (!examples[domain]) {
            examples[domain] = file;
        }
    }
    END {
        # Output results sorted by count (descending)
        for (domain in count) {
            printf "%-30s  %5d  %s\n", domain, count[domain], examples[domain];
        }
    }' | sort -k2,2nr
    
    echo ""
    echo "Done listing unique image domains."
