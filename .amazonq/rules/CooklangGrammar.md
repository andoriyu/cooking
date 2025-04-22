# CookLang Grammar Guide

This document provides a comprehensive overview of CookLang syntax for Amazon Q to reference when working with recipe files.

## Basic Structure

A CookLang recipe consists of:
1. Optional YAML metadata header (between `---` delimiters)
2. Recipe steps as plain text
3. Special markup for ingredients, cookware, timers, and metadata

## Metadata Header

```yaml
---
title: Recipe Title
tags:
  - tag1
  - tag2
servings: 4
time:
  prep: 10 minutes
  cook: 30 minutes
difficulty: easy
nutrition:
  protein: 20g
  carbs: 30g
  fat: 10g
  calories: 350
  sugar: 5g
  alcohol: 0%
image: https://example.com/recipe-image.jpg
source:
  author: Recipe Author
  url: https://example.com/original-recipe
  youtube: https://youtube.com/watch?v=example
verified: true
---
```

### Metadata Fields TL;DR

- **title**: Recipe name displayed as the main heading
- **tags**: Categorization labels for filtering and organization
- **servings**: Number of portions the recipe yields
- **time**:
  - **prep**: Time needed for preparation (include units)
  - **cook**: Time needed for cooking (include units)
- **difficulty**: Complexity level (easy, medium, hard)
- **nutrition**: Nutritional information
  - **protein**: Protein content (include units, typically g)
  - **carbs**: Carbohydrate content (include units, typically g)
  - **fat**: Fat content (include units, typically g)
  - **calories**: Calorie content (numeric value, assumed to be kcal)
  - **sugar**: Sugar content (include units, typically g)
  - **alcohol**: Alcohol content (include percentage)
- **image**: URL to recipe hero image
- **source**: Attribution information
  - **author**: Recipe creator (use "ai" for AI-generated recipes)
  - **url**: Link to original recipe
  - **youtube**: Link to related YouTube video
- **verified**: Boolean indicating if recipe has been tested (true/false)

## Ingredients

Ingredients are marked with `@` and can include quantity, units, and shorthand preparations:

```
@ingredient
@ingredient{quantity}
@ingredient{quantity%unit}
@ingredient(preparation)
@ingredient{quantity}(preparation)
@ingredient{quantity%unit}(preparation)
```

Examples:
- `@salt`
- `@butter{200%g}`
- `@eggs{2}`
- `@olive oil{2%tbsp}`
- `@onion{1}(peeled and finely chopped)`
- `@garlic{2%cloves}(peeled and minced)`

## Cookware

Cookware items are marked with `#` and should only be marked on their first appearance in the recipe steps. For multi-word cookware items, the entire name must be included in the markup:

```
#cookware
#multi word cookware{}
```

Examples:
- `#bowl`
- `#potato masher{}`
- `#cast iron skillet{}`

## Timers

Timers are marked with `~` and include a name and duration:

```
~name{duration}
~name{duration%unit}
```

Examples:
- `~{10%minutes}`
- `~eggs{3%minutes}`
- `~baking{30%minutes}`

## Comments

Line comments are marked with `--` and are ignored when parsing:

```
-- This is a comment
```

Block comments use `[-` and `-]` delimiters:

```
[- This is a block comment that can span
   multiple lines -]
```

Example:
- `[- TODO change units to litres -]`

## Step Separation

Steps must be separated by blank lines. Each paragraph in the recipe text is considered a separate step.

## Example Recipe

```
-- Pancake Recipe

Whisk together @flour{2%cups}, @sugar{2%tbsp}, @baking powder{1%tsp}, and @salt{1/2%tsp} in a #large bowl{}.

In a separate #bowl, combine @milk{1.5%cups}, @eggs{2}, and @butter{3%tbsp}(melted).

[- TODO: Add alternative for dairy-free version -]

Pour the wet ingredients into the dry ingredients and stir until just combined. Let the batter rest for ~resting{5%minutes}.

Heat a #non-stick pan{} over medium heat. Pour @batter{1/4%cup} onto the pan for each pancake.

Cook until bubbles form on the surface, about ~cooking{2%minutes}, then flip and cook for ~finishing{1%minute} more.
```

## References

- [CookLang Official Specification](https://cooklang.org/docs/spec/)
- [CookLang Best Practices](https://cooklang.org/docs/best-practices/)
