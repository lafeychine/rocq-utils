{ nixpkgs }:

with nixpkgs.lib;
{
  mkFmt = str: removePrefix "v" (replaceStrings [ "." ] [ "_" ] str);

  mkRocqConstraints = import ./mkRocqConstraints.nix;
  mkRocqPackages = import ./mkRocqPackages.nix;
}
