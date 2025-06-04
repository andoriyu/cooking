# Recipe Frontmatter Validation

This document describes the validation rules for recipe frontmatter in YAML format.

## Required Fields

### Title
- **Field**: `title`
- **Format**: Must start with a capital letter (Unicode characters allowed)
- **Pattern**: `^[A-Z].*$`
- **Example**: `title: Lebanese Spicy Potatoes (Batata Harra)`

### Tags
- **Field**: `tags`
- **Format**: List with at least one tag; every tag must be lowercase letters, digits, or hyphens (including en-dash)
- **Pattern**: `^[a-z0-9‑-]+$`
- **Example**:
  ```yaml
  tags:
    - potatoes
    - lebanese
    - side‑dish
  ```

### Servings
- **Field**: `servings`
- **Format**: Positive integer (1 or greater)
- **Pattern**: `^[1-9][0-9]*$`
- **Example**: `servings: 8`

### Difficulty
- **Field**: `difficulty`
- **Format**: Must be one of: easy, medium, hard
- **Pattern**: `^(easy|medium|hard)$`
- **Example**: `difficulty: easy`

## Optional Fields

### Time Block
- **Field**: `time`
- **Format**: If present, must contain at least a `prep` field
- **Example**:
  ```yaml
  time:
    prep: 10 minutes
    cook: 35 minutes
  ```

### Nutrition Block
- **Field**: `nutrition`
- **Format**: Optional block with specific format requirements for each subfield
- **Subfields**:
  - `calories`: Numbers only (e.g., `calories: 250`)
  - `protein`: Numbers followed by 'g' (e.g., `protein: 15g`)
  - `carbs`: Numbers followed by 'g' (e.g., `carbs: 30g`)
  - `fat`: Numbers followed by 'g' (e.g., `fat: 10g`)
  - `sugar`: Numbers followed by 'g' (e.g., `sugar: 5g`)
  - `alcohol`: Numbers followed by '%' (e.g., `alcohol: 12%`)

### Image
- **Field**: `image`
- **Format**: HTTP/HTTPS URL ending with image extension
- **Pattern**: `^https?://.+\.(jpg|jpeg|png|webp)(\?.*)?$`
- **Example**: `image: https://example.com/image.jpg`

## Validation Rules

```gritql
engine marzano(0.1)
language yaml

// ──────────────────────────────
//  Required‑field validators
// ──────────────────────────────
pattern validTitle() {
  // Title must start with a capital letter (Unicode characters allowed)
  `title: $title` where {
    $title <: r"^[A-Z].*$"
  }
}

pattern validTags() {
  // Need at least one tag; every tag must be lowercase letters / digits / hyphens (including en-dash)
  `tags:
    $tags` where {
    $tags <: some r"^[a-z0-9‑-]+$"
  }
}

pattern validServings() {
  `servings: $n` where { $n <: r"^[1-9][0-9]*$" }
}

pattern validDifficulty() {
  `difficulty: $lvl` where { $lvl <: r"^(easy|medium|hard)$" }
}

// ──────────────────────────────
//  Optional block: time
//  (At least a prep time is required *if* the block exists.)
// ──────────────────────────────
pattern validTime() {
  maybe `time: $body` where {
    // Must contain a 'prep:' line; any other lines (cook, total, etc.) are fine
    $body <: contains `prep: $prep`
  }
}

// ──────────────────────────────
//  Nutrition helpers
//  (Each key is optional but, if present, must match its format.)
// ──────────────────────────────
pattern nutritionCalories() { `calories: $v` where { $v <: r"^[0-9]+$"  } }
pattern nutritionProtein()  { `protein:  $v` where { $v <: r"^[0-9]+g$" } }
pattern nutritionCarbs()    { `carbs:    $v` where { $v <: r"^[0-9]+g$" } }
pattern nutritionFat()      { `fat:      $v` where { $v <: r"^[0-9]+g$" } }
pattern nutritionSugar()    { `sugar:    $v` where { $v <: r"^[0-9]+g$" } }
pattern nutritionAlcohol()  { `alcohol:  $v` where { $v <: r"^[0-9]+%$" } }

// --------------- nutrition block ---------------
pattern validNutrition() {
  maybe `nutrition: $nut` where {
    $nut <: maybe contains nutritionCalories(),
    $nut <: maybe contains nutritionProtein(),
    $nut <: maybe contains nutritionCarbs(),
    $nut <: maybe contains nutritionFat(),
    $nut <: maybe contains nutritionSugar(),
    $nut <: maybe contains nutritionAlcohol()
  }
}

// ──────────────────────────────
//  Optional block: image URL
// ──────────────────────────────
pattern validImage() {
  maybe `image: $url` where {
    $url <: r"^https?://.+\\.(jpg|jpeg|png|webp)(\\?.*)?$"
  }
}

// ──────────────────────────────
//  Top‑level validator
// ──────────────────────────────
pattern validateRecipeFrontmatter() {
  sequential {
    validTitle(),
    validTags(),
    validServings(),
    validDifficulty(),
    validTime(),
    validNutrition(),
    validImage()
  }
}

// Apply the validation pattern
validateRecipeFrontmatter()
```

## Usage

This validation pattern ensures that all recipe files follow a consistent format for their YAML frontmatter, making them easier to parse and process programmatically.