{
  description = "My Custom NixOS Configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
  };

  outputs = inputs@{ nixpkgs, flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      
      flake = {
        nixosConfigurations.zenko = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            (import-tree ./packages)
            (import-tree ./modules)
            (import-tree ./hosts)
            (import-tree ./homes)
          ];
        };
      };
      
      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nixd
            pkgs.nixfmt
          ];
        };
      };
    };
}