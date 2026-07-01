let
  case = case: out: { inherit case out; };

  # NOTE: If possible, upstream these matrices
  # It might not be accepted as overlapping is useless upstream
  mkRocqPackages =
    base:
    base.overrideScope (
      final: prev:
      with final.lib;
      with final.lib.versions;
      {
        stdlib = overrideRocqDerivation {
          defaultVersion = switch final.rocq-core.rocq-version [
            (case (range "9.0" "9.2") "9.1.0")
            (case (range "9.0" "9.1") "9.0.0")
          ] null;
        } prev.stdlib;

        rocq-elpi = overrideRocqDerivation {
          pname = "rocq-elpi";

          defaultVersion = switch final.rocq-core.rocq-version [
            (case (range "9.0" "9.2") "3.4.0")
            (case (range "9.0" "9.2") "3.3.1")
            (case (range "9.0" "9.1") "3.2.0")
          ] null;

          propagatedBuildInputs =
            let
              elpi-version = switch final.rocq-elpi.version [
                (case (versions.isEq "3.4.0") "3.7.1")
                (case (versions.isEq "3.3.1") "3.6.2")
                (case (versions.isEq "3.2.0") "3.4.5")
              ] null;
            in
            [
              final.rocq-core.ocamlPackages.findlib
              final.rocq-core.ocamlPackages.ppx_optcomp
              (final.rocq-core.ocamlPackages.elpi.override { version = elpi-version; })
            ];

          release = {
            "3.4.0".sha256 = "sha256-8x2Sa/+pUpXEqB+NdyfOyw6Yyzp6Q1k5LnhrjG/qJNM=";
            "3.3.1".sha256 = "sha256-/ehf2g/+riXOmfXs90Mx0PnKA0wJyombHK+rbVePjw0=";
            "3.2.0".sha256 = "sha256-FyYG/8lEyt1L/paMez8jYAnnUE+sxIp4Da5MztmwJ/c=";
          };
        } prev.rocq-elpi;
      }
    );
in

final: prev:
let
  # NOTE: Waiting the version 3.23 of Dune for Rocq 9.0 builds
  # See: https://github.com/ocaml/dune/pull/14093
  rocqPackages_9_0 = prev.rocqPackages_9_0.overrideScope (
    _: _: {
      dune = prev.ocamlPackages.dune_3.overrideAttrs rec {
        version = "3.23.1";

        src = final.fetchurl {
          url = "https://github.com/ocaml/dune/releases/download/3.23.1/dune-3.23.1.tbz";
          hash = "sha256-k7TnFX9rqP62HPxfhgCO/SxZA3unigF9krSr8wYyNI8=";
        };
      };
    }
  );
in
{
  rocqPackages = mkRocqPackages prev.rocqPackages;

  rocqPackages_9_0 = mkRocqPackages rocqPackages_9_0;
  rocqPackages_9_1 = mkRocqPackages prev.rocqPackages_9_1;
  rocqPackages_9_2 = mkRocqPackages prev.rocqPackages_9_2;
}
