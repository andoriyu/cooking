{
  description = "Cooking utilities – generate phrases.json from Cooklang files";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05"; # Pin to a stable release
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
        };
      };
    in {
      ## 1.2.1 Package: generate-timer-phrases
      packages.generate-timer-phrases = pkgs.writeShellApplication {
        name = "generate-timer-phrases";
        runtimeInputs = [pkgs-unstable.cook-cli pkgs.jq]; # cook-cli from unstable, jq from stable
        text = builtins.readFile ./scripts/generate-timer-phrases.sh;
      };

      ## 1.2.2 Default package alias
      packages.default = self.packages.${system}.generate-timer-phrases;

      ## 1.2.3 Dev shell (with pre-commit hooks)
      devShells.default = pkgs.mkShell {
        inputsFrom = [self.packages.${system}.generate-timer-phrases];
        inherit (pre-commit-check) shellHook;
        nativeBuildInputs =
          [
            pkgs.shellcheck
            pkgs.bashInteractive
            pkgs.alejandra
            pkgs.statix
          ]
          ++ pre-commit-check.enabledPackages;
        # Optional: add other tooling (e.g., jq, cook-cli) if you want to run locally
      };

      ## 1.2.4 Pre-commit checks
      checks = {
        inherit pre-commit-check;
      };
    });
}
