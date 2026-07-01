{
  description = "Utilities for Rocq projects";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      flake = {
        lib = import ./lib.nix { inherit nixpkgs; };
        overlays.default = import ./overlay.nix;
      };

      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt-tree;
      };
    };
}
