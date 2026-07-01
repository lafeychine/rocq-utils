pkgs: rocq-version:

with pkgs.lib;
let
  version = concatStringsSep "_" (take 2 (splitVersion rocq-version));
  subset = "rocqPackages_${version}";
in
if hasAttr subset pkgs then
  pkgs.${subset}
else
  pkgs.rocqPackages.overrideScope (
    _: prev: {
      rocq-core = prev.rocq-core.override { inherit version; };
    }
  )
