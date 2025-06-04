#!/bin/sh
set -eu

# Script to validate recipe frontmatter according to the gritql schema
# This script validates .cook files' YAML frontmatter

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to extract YAML frontmatter from a .cook file
extract_frontmatter() {
    file="$1"
    if [ ! -f "$file" ]; then
        echo "File not found: $file" >&2
        return 1
    fi
    
    # Extract content between --- markers
    awk '/^---$/{flag=!flag; if(!flag) exit} flag && !/^---$/' "$file"
}

# Function to validate a single field with regex using grep
validate_field() {
    field_name="$1"
    field_value="$2"
    pattern="$3"
    required="$4"
    
    if [ -z "$field_value" ]; then
        if [ "$required" = "true" ]; then
            printf "${RED}ERROR: Required field '%s' is missing${NC}\n" "$field_name" >&2
            return 1
        else
            return 0
        fi
    fi
    
    # Use grep for pattern matching instead of bash regex
    if ! echo "$field_value" | grep -qE "$pattern"; then
        printf "${RED}ERROR: Field '%s' has invalid format: '%s'${NC}\n" "$field_name" "$field_value" >&2
        printf "${YELLOW}Expected pattern: %s${NC}\n" "$pattern" >&2
        return 1
    fi
    
    return 0
}

# Function to validate tags
validate_tags() {
    frontmatter="$1"
    
    # Extract tags section
    tags_section=$(echo "$frontmatter" | awk '/^tags:/{flag=1; next} /^[a-zA-Z]/ && flag{flag=0} flag{print}')
    
    if [ -z "$tags_section" ]; then
        printf "${RED}ERROR: Required field 'tags' is missing${NC}\n" >&2
        return 1
    fi
    
    # Check if we have at least one tag
    tag_count=$(echo "$tags_section" | grep -c "^[[:space:]]*-" || true)
    if [ "$tag_count" -eq 0 ]; then
        printf "${RED}ERROR: At least one tag is required${NC}\n" >&2
        return 1
    fi
    
    # Validate each tag
    echo "$tags_section" | grep "^[[:space:]]*-" | while read -r line; do
        tag=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')
        if ! echo "$tag" | grep -qE "^[a-z0-9‑-]+$"; then
            printf "${RED}ERROR: Invalid tag format: '%s'${NC}\n" "$tag" >&2
            printf "${YELLOW}Tags must be lowercase letters, digits, or hyphens only${NC}\n" >&2
            return 1
        fi
    done
}

# Function to validate nutrition block
validate_nutrition() {
    frontmatter="$1"
    
    # Check if nutrition block exists
    if ! echo "$frontmatter" | grep -q "^nutrition:"; then
        return 0  # Optional field
    fi
    
    # Extract nutrition section
    nutrition_section=$(echo "$frontmatter" | awk '/^nutrition:/{flag=1; next} /^[a-zA-Z]/ && flag{flag=0} flag{print}')
    
    # Check for required nutrition fields
    for field in calories protein carbs fat; do
        if ! echo "$nutrition_section" | grep -q "^[[:space:]]*$field:"; then
            printf "${RED}ERROR: Nutrition block missing required field: %s${NC}\n" "$field" >&2
            return 1
        fi
    done
    
    return 0
}

# Function to validate time block
validate_time() {
    frontmatter="$1"
    
    # Check if time block exists
    if ! echo "$frontmatter" | grep -q "^time:"; then
        return 0  # Optional field
    fi
    
    # Extract time section
    time_section=$(echo "$frontmatter" | awk '/^time:/{flag=1; next} /^[a-zA-Z]/ && flag{flag=0} flag{print}')
    
    # Check for required prep field
    if ! echo "$time_section" | grep -q "^[[:space:]]*prep:"; then
        printf "${RED}ERROR: Time block missing required field: prep${NC}\n" >&2
        return 1
    fi
    
    return 0
}

# Function to validate a single .cook file
validate_file() {
    file="$1"
    errors=0
    
    printf "Validating: %s\n" "$file"
    
    # Extract frontmatter
    frontmatter=$(extract_frontmatter "$file")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    if [ -z "$frontmatter" ]; then
        printf "${RED}ERROR: No YAML frontmatter found${NC}\n" >&2
        return 1
    fi
    
    # Extract individual fields
    title=$(echo "$frontmatter" | awk '/^title:/ {sub(/^title:[[:space:]]*/, ""); print}')
    servings=$(echo "$frontmatter" | awk '/^servings:/ {sub(/^servings:[[:space:]]*/, ""); print}')
    difficulty=$(echo "$frontmatter" | awk '/^difficulty:/ {sub(/^difficulty:[[:space:]]*/, ""); print}')
    image=$(echo "$frontmatter" | awk '/^image:/ {sub(/^image:[[:space:]]*/, ""); print}')
    
    # Validate required fields
    validate_field "title" "$title" "^[A-Z].*$" "true" || errors=$((errors + 1))
    validate_field "servings" "$servings" "^[1-9][0-9]*$" "true" || errors=$((errors + 1))
    validate_field "difficulty" "$difficulty" "^(easy|medium|hard)$" "true" || errors=$((errors + 1))
    
    # Validate optional fields
    if [ -n "$image" ]; then
        validate_field "image" "$image" "^https?://.*\.(jpg|jpeg|png|gif|webp)$" "false" || errors=$((errors + 1))
    fi
    
    # Validate complex fields
    validate_tags "$frontmatter" || errors=$((errors + 1))
    validate_nutrition "$frontmatter" || errors=$((errors + 1))
    validate_time "$frontmatter" || errors=$((errors + 1))
    
    if [ $errors -eq 0 ]; then
        printf "${GREEN}✓ %s is valid${NC}\n" "$file"
        return 0
    else
        printf "${RED}✗ %s has %d validation error(s)${NC}\n" "$file" $errors >&2
        return 1
    fi
}

# Main script logic
main() {
    # Check if any files provided
    if [ $# -eq 0 ]; then
        # Find all .cook files in current directory and subdirectories
        files=$(find . -name "*.cook" -type f)
        if [ -z "$files" ]; then
            echo "No .cook files found in current directory"
            exit 0
        fi
        # Convert to positional parameters
        set -- $files
    fi
    
    total_files=$#
    failed_files=0
    
    printf "Validating %d .cook file(s)...\n\n" $total_files
    
    # Process each file
    for file in "$@"; do
        if ! validate_file "$file"; then
            failed_files=$((failed_files + 1))
        fi
        echo
    done
    
    # Summary
    if [ $failed_files -eq 0 ]; then
        printf "${GREEN}All files passed validation!${NC}\n"
        exit 0
    else
        printf "${RED}%d out of %d files failed validation${NC}\n" $failed_files $total_files >&2
        exit 1
    fi
}

# Run main function with all arguments
main "$@"