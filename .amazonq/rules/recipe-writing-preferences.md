# Recipe Writing Preferences

This document outlines the preferred style and formatting for recipes in this collection.

## General Structure

- Each recipe should be in a `.cook` file using CookLang syntax
- Recipes should be organized in appropriate category folders (e.g., `recipes/Cocktails/`)
- File names should use underscores for spaces (e.g., `Cloud_Lily.cook`)

## Measurement Systems

- For food recipes, use the metric system (g, kg, ml, l)
- For cocktail recipes, use imperial measurements (oz, tsp, tbsp)
- For temperatures, use Fahrenheit (°F) in all recipes

## Metadata

- Always include complete metadata at the top of each recipe
- Required metadata fields:
  - `title`: The full recipe name
  - `tags`: Relevant categories and ingredients (include main spirit for cocktails)
  - `servings`: Number of servings the recipe makes
  - `time`: Preparation and cooking time
  - `difficulty`: How challenging the recipe is (easy, medium, hard)
  - `nutrition`: Nutritional information when available
  - `image`: URL to an image of the finished dish/drink

## Ingredient Formatting

- Mark all ingredients with `@` symbol
- Include quantities and units when applicable: `@ingredient{quantity%unit}`
- For preparation methods that are part of the ingredient, use parentheses: `@ingredient{quantity%unit}(preparation)`
- When a preparation is more involved, make it a separate step rather than part of the ingredient notation
- Mark ice as an ingredient when it's added to a recipe: `@ice{}`

## Cookware Formatting

- Mark cookware items with `#` symbol
- For multi-word cookware items, use empty braces: `#mixing glass{}`
- Only mark cookware on its first appearance in the recipe
- Be specific about the type of cookware when relevant

## Step Writing

- Separate steps with blank lines
- Write steps in clear, concise language
- Use complete sentences with imperative verbs
- Break complex procedures into multiple steps
- Include visual cues for doneness when applicable

## Comments

- Use comments (`-- Note:`) at the end of recipes for variations or tips
- Use block comments (`[- comment -]`) for notes that should be addressed later

## Timers

- Only use timers (`~name{duration%unit}`) for significant waiting periods
- For very short durations (under 30 seconds), timers are not necessary
- Include descriptive names for timers when possible

## Example

```
---
title: Classic Negroni
tags:
  - cocktail
  - italian
  - aperitif
  - gin
servings: 1
time:
  prep: 2 minutes
difficulty: easy
nutrition:
  calories: 195
  carbs: 10g
  sugar: 10g
  alcohol: 24%
image: https://example.com/negroni.jpg
---

Add @gin{1%oz}, @Campari{1%oz}, and @sweet vermouth{1%oz} to a #mixing glass{} filled with ice.

Stir well until the mixture is well chilled.

Strain into a #rocks glass{} with a large #ice cube{}.

Cut a piece of @orange peel{1}.

Express the orange peel over the drink by twisting it, then rub it along the rim of the glass before dropping it into the cocktail.

-- Note: For the best flavor, use a quality sweet vermouth and keep it refrigerated after opening.
```
