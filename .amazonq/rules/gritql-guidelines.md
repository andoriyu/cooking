# GritQL Usage Guidelines for Recipe Validation

When working with GritQL for recipe frontmatter validation:

1. Use the `engine marzano(0.1)` directive to specify the GritQL engine version.

2. Specify the `language yaml` to ensure proper parsing of YAML frontmatter.

3. Create individual patterns for each validation rule:
   - Use descriptive pattern names like `validTitle()`, `validTags()`, etc.
   - Group related validations into logical units

4. For field validation:
   - Use backticks for literal text matching: `` `title: $title` ``
   - Use variables with `$` prefix to capture values: `$title`, `$n`, `$lvl`
   - Use the `where` clause with the `<:` operator for regex validation
   - Use `r"..."` syntax for regex patterns

5. For optional fields:
   - Use the `maybe` keyword before the pattern
   - Example: `maybe `image: $url` where {...}`

6. For nested structures:
   - Use indentation in the pattern to match YAML structure
   - Example: `` `tags:\n    $tags` ``

7. For complex validations:
   - Create helper patterns for reusable components
   - Use `contains` to check for presence of subpatterns
   - Use `sequential` to enforce order of patterns

8. For the main validation pattern:
   - Create a comprehensive pattern that combines all individual validations
   - Apply the pattern at the end of the file

9. Use regex patterns appropriately:
   - `r"^[A-Z][A-Za-z0-9 ',.&-]+$"` for title case validation
   - `r"^[a-z0-9-]+$"` for lowercase tags
   - `r"^[1-9][0-9]*$"` for positive integers
   - `r"^(easy|medium|hard)$"` for enumerated values

10. Use comments to document the purpose and requirements of each pattern.

## Example Pattern Structure

```gritql
engine marzano(0.1)
language yaml

// Required field validator
pattern validTitle() {
  `title: $title` where {
    $title <: r"^[A-Z][A-Za-z0-9 ',.&-]+$"
  }
}

// Optional field validator with nested structure
pattern validNutrition() {
  maybe `nutrition: $nut` where {
    $nut <: maybe contains `calories: $cal` where { $cal <: r"^[0-9]+$" }
  }
}

// Main validation pattern combining all rules
pattern validateRecipeFrontmatter() {
  sequential {
    validTitle(),
    // Other validators...
  }
}

// Apply the validation pattern
validateRecipeFrontmatter()
```
