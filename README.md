# What's next

* Install a syntax highlighting package for your text editor. We have packages for SublimeText and VSCode. See  [cooklang.org](https://cooklang.org/docs/syntax-highlighting/) for full instructions.
* Add your own recipes. Dive into the Cook ecoysystem and discover how easy it is to write in CookLang. It's the best way to learn the [CookLang syntax](https://cooklang.org/docs/spec/).
* Check out our [tips and tricks](https://cooklang.org/docs/best-practices/) page.

## Recipe Frontmatter Validation

This repository includes validation for recipe YAML frontmatter to ensure consistency across all recipe files. The validation is implemented using POSIX shell scripts for maximum compatibility and is automatically run as a pre-commit hook.

### Manual Validation

```sh
# Validate all .cook files
./scripts/validate-frontmatter.sh

# Validate specific files
./scripts/validate-frontmatter.sh recipes/pasta/*.cook

# View validation rules
cat .grit/frontmatter-schema.md
```

### Pre-commit Hook

The validation runs automatically on staged `.cook` files when you commit. To set up the development environment with pre-commit hooks:

```sh
nix develop
```

This ensures all recipe files follow the required frontmatter schema before being committed.

## Generate Timer Phrases

This repository includes a utility to extract timer information from Cooklang recipe files and generate notification phrases for cooking assistants.

### Using Nix (recommended)

```sh
# Generate timer phrases from all .cook files in current directory
nix run . -- .

# Generate from specific directory
nix run . -- recipes/

# View the generated phrases
cat phrases.json
```

### Direct execution

```sh
# Make script executable
chmod +x scripts/generate-timer-phrases.sh

# Generate timer phrases
./scripts/generate-timer-phrases.sh tests/

# Check results
jq '.count' phrases.json
```

The utility generates a `phrases.json` file with structured timer data like:

```json
{
  "cook_garlic|30|seconds": "Chef, your cook garlic timer is done.",
  "simmer|10|minutes": "Chef, your 10 minutes timer is done."
}
```

### Read the recipe

```sh
cook recipe read "Root Vegetable Tray Bake.cook"
```

### Create shopping list

```sh
cook shopping-list \
  "Neapolitan Pizza.cook" \
  "Root Vegetable Tray Bake.cook" \
  "Snack Basket I.cook"
```

### Run a server

In directory where you have your recipes run:

```sh
cook server
```

Then open [http://127.0.0.1:9080](http://127.0.0.1:9080) in your browser.

### Automate something

Explore [the docs](https://cooklang.org/cli/help/), which describe how to use CookCLI's automation tools.

### Customize your instance

Add aisle configuration information to the `config/aisle.conf` file to tailor your shopping list experience.




