# My Cooking Collection

This repository contains my personal collection of recipes written in [CookLang](https://cooklang.org/), a markup language specifically designed for recipes.

## 🌐 Website

This recipe collection is hosted at [https://recipes.coldsteel.casa](https://recipes.coldsteel.casa)

## 🍽️ What's Inside

The repository includes various recipes organized by categories:
- Breakfasts
- Pasta dishes
- Breads
- Salads
- Healthyish options
- Sunday Roast
- Wraps
- And more individual recipes like Borsch, Neapolitan Pizza, etc.

## 📋 Recipe Metadata

Each recipe supports the following metadata format at the beginning of the file:

```
---
title: Fluffy Buttermilk Pancakes
tags:
  - breakfast
  - brunch
  - vegetarian
  - weekend
servings: 4 (12 pancakes)
time:
  prep: 10 minutes
  cook: 15 minutes
difficulty: easy
nutrition:
  protein: 7g
  carbs: 30g
  fat: 9g
image: https://example.com/pancakes.jpg
---
```

This metadata is used for categorization, filtering, and displaying additional information on the website. The `image` field can be used to specify a URL to an image of the finished recipe.

## 🚀 Deployment

This recipe collection is automatically deployed to GitHub Pages using a custom workflow that:
1. Uses the private `pan_press` repository for the website framework
2. Copies the recipes from this repository into the website project
3. Builds and deploys the site using Astro

The site is rebuilt and deployed automatically whenever changes are pushed to the main branch.

## 🛠️ Local Usage

### Prerequisites

- Install [CookCLI](https://cooklang.org/cli/get-started/)
- A text editor with CookLang syntax highlighting (available for VSCode, SublimeText, and others)

### Reading Recipes

```sh
cook recipe read "recipes/Root Vegetable Tray Bake.cook"
```

### Creating Shopping Lists

```sh
cook shopping-list \
  "recipes/Neapolitan Pizza.cook" \
  "recipes/Root Vegetable Tray Bake.cook" \
  "recipes/Snack Basket I.cook"
```

### Running a Local Server

To browse recipes in a web interface:

```sh
cook server
```

Then open [http://127.0.0.1:9080](http://127.0.0.1:9080) in your browser.

## 📝 Contributing

To add a new recipe:
1. Create a new `.cook` file in the appropriate category folder
2. Follow the [CookLang syntax](https://cooklang.org/docs/spec/)
3. Commit and push to the repository

## 🔗 Useful Links

- [CookLang Official Website](https://cooklang.org/)
- [CookLang Syntax Documentation](https://cooklang.org/docs/spec/)
- [CookLang Best Practices](https://cooklang.org/docs/best-practices/)
- [CookCLI Documentation](https://cooklang.org/cli/help/)
