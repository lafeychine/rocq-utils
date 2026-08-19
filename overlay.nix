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
