{
  description = "Cooking utilities – generate phrases.json from Cooklang files";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-24.05";    # Pin to a stable release
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        ## 1.2.1 Package: generate-timer-phrases
        packages.generate-timer-phrases = pkgs.writeShellApplication {
          name          = "generate-timer-phrases";
          runtimeInputs = [ pkgs.cook-cli pkgs.jq ];  # Requires cook and jq
          text          = builtins.readFile ./scripts/generate-timer-phrases.sh;
        };

        ## 1.2.2 Default package alias
        defaultPackage = self.packages.${system}.generate-timer-phrases;

        ## 1.2.3 Dev shell (with Alejandra available)
        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.generate-timer-phrases ];
          nativeBuildInputs = [
            pkgs.shellcheck
            pkgs.bashInteractive
            pkgs.alejandra
          ];
          # Optional: add other tooling (e.g., jq, cook-cli) if you want to run locally
        };
      });
}