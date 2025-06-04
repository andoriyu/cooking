{
  description = "Cooking utilities – generate phrases.json from Cooklang files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # Pin to a stable release
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # For cook-cli
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    git-hooks,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      pkgs-unstable = import nixpkgs-unstable {inherit system;};

      # Configure pre-commit hooks
      pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          shellcheck.enable = true;
          statix.enable = true;
          actionlint.enable = true;

          # Custom hook for recipe frontmatter validation
          frontmatter-validation = {
            enable = true;
            name = "Recipe frontmatter validation";
            entry = "/bin/sh ./scripts/validate-frontmatter-precommit.sh";
            files = "\\.cook$";
            language = "system";
            description = "Validate YAML frontmatter in .cook recipe files";
          };
        };
      };
    in {
      # Package: generate-timer-phrases
      packages.generate-timer-phrases = pkgs.writeShellApplication {
        name = "generate-timer-phrases";
        runtimeInputs = [pkgs-unstable.cook-cli pkgs.jq]; # cook-cli from unstable, jq from stable
        text = builtins.readFile ./scripts/generate-timer-phrases.sh;
      };

      # Default package alias
      packages.default = self.packages.${system}.generate-timer-phrases;

      # Dev shell (with pre-commit hooks)
      devShells.default = pkgs.mkShell {
        inputsFrom = [self.packages.${system}.generate-timer-phrases];
        inherit (pre-commit-check) shellHook;
        nativeBuildInputs =
          [
            pkgs.shellcheck
            pkgs.bashInteractive
            pkgs.alejandra
            pkgs.statix
            pkgs.actionlint
          ]
          ++ pre-commit-check.enabledPackages;
        # Optional: add other tooling (e.g., jq, cook-cli) if you want to run locally
      };

      # Pre-commit checks
      checks = {
        inherit pre-commit-check;
      };

      # Omnix CI configuration
      om.ci.default = {
        root.dir = ".";
      };
    });
}
