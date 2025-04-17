#!/bin/bash

# Create directories in the root that match subdirectories in recipes/
for dir in $(find recipes -type d -depth 1); do
  # Skip the recipes directory itself
  if [ "$dir" = "recipes" ]; then
    continue
  fi
  
  # Extract the directory name without the recipes/ prefix
  dir_name=$(basename "$dir")
  
  # Create the directory in the root if it doesn't exist
  mkdir -p "$dir_name"
  
  # Copy all files from the subdirectory to the new directory
  cp -r "$dir"/* "$dir_name"/
  
  echo "Copied contents from $dir to $dir_name"
done

# Move all .cook files directly in the recipes/ folder to the root
for file in recipes/*.cook; do
  # Check if there are any matching files
  if [ -e "$file" ]; then
    # Get just the filename
    filename=$(basename "$file")
    
    # Copy the file to the root
    cp "$file" "./$filename"
    
    echo "Copied $file to ./$filename"
  fi
done

# Copy any README.md files that might be in recipes/ (but not in subdirectories)
if [ -f "recipes/README.md" ]; then
  cp "recipes/README.md" "./recipes_README.md"
  echo "Copied recipes/README.md to ./recipes_README.md"
fi

echo "All recipe files have been copied. Please verify the files are in the correct locations before removing the recipes directory."
