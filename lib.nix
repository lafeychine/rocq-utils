{ nixpkgs }:

with nixpkgs.lib;
{
  mkFmt = str: removePrefix "v" (replaceStrings [ "." ] [ "_" ] str);

  mkRocqConstraints = import ./mkRocqConstraints.nix { inherit nixpkgs; };
  mkRocqPackages = import ./mkRocqPackages.nix;
}
