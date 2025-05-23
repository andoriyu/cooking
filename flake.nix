{
  description = "A collection of recipes with phrase generation and other utilities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    # Define named apps that can be run with `nix run .#<app-name>`
    apps = nixpkgs.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        generate-phrases = {
          type = "app";
          program = toString (pkgs.writeShellScriptBin "generate-phrases-script" ''
            # Ensure the script runs from the flake's root
            cd ${self}
            # Execute the original script, passing the recipes directory as an argument
            ./get-phrases.sh "."
          ''}/bin/generate-phrases-script);
          
          # Define dependencies needed by the script when it runs
          meta.mainProgram = "generate-phrases-script";
        };
      }
    );

    # Optional: A devShell for interactive development
    devShells = nixpkgs.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      pkgs.mkShell {
        buildInputs = with pkgs; [
          cook-cli
          jq
          findutils # For `find`
        ];
        shellHook = ''
          echo "Welcome to the recipe development shell!"
          echo "You can run './get-phrases.sh' directly here, or use the declarative 'nix run .#generate-phrases'."
        '';
      }
    );
  };
}