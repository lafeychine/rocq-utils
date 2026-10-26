pkgs: rocq-version:

with pkgs.lib;
let
  isVersion = v: match "^[0-9]+(\.[0-9]+){2}$" v != null;
  mkSubset = v: "rocqPackages_${concatStringsSep "_" (take 2 (splitVersion v))}";
in
if isVersion rocq-version && hasAttr (mkSubset rocq-version) pkgs then
  pkgs.${mkSubset rocq-version}
else
  pkgs.rocqPackages.overrideScope (
    _: prev: {
      rocq-core = prev.rocq-core.override { version = rocq-version; };
    }
  )
