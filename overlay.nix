let
  case = case: out: { inherit case out; };

  # NOTE: If possible, upstream these matrices
  # It might not be accepted as overlapping is useless upstream
  patchRocqPackages =
    base:
    base.overrideScope (
      final: prev:
      with final.lib;
      with final.lib.versions;
      {
        stdlib = overrideRocqDerivation {
          defaultVersion = switch final.rocq-core.rocq-version [
            (case (range "9.1" "9.3") "9.2.0")
            (case (range "9.0" "9.2") "9.1.0")
            (case (range "9.0" "9.1") "9.0.0")
          ] null;

          release = {
            "9.2.0".sha256 = "sha256-ySNY8XUQOH6B1B2p+39jdJ7UjIMrRDl499JJwpLEHuM=";
            "9.1.0".sha256 = "sha256-D/kCMsJDg5OnP37GhvXIr2Fi/xCbgCCzoikKx5rL6p4=";
            "9.0.0".sha256 = "sha256-2l7ak5Q/NbiNvUzIVXOniEneDXouBMNSSVFbD1Pf8cQ=";
          };
        } prev.stdlib;
      }
    );

  mkRocqPackages =
    prev:
    { version, hash }:
    prev.mkRocqPackages (
      prev.rocqPackages.rocq-core.override {
        version = {
          inherit version;
          location = {
            inherit hash;
            rev = "V${version}";
          };
        };
      }
    );
in

final: prev:
let
  # NOTE: Waiting the version 3.23 of Dune for Rocq 9.0 builds (nixos-26.11)
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
  rocqPackages = patchRocqPackages prev.rocqPackages;

  rocqPackages_9_0 = patchRocqPackages rocqPackages_9_0;
  rocqPackages_9_1 = patchRocqPackages prev.rocqPackages_9_1;
  rocqPackages_9_2 = patchRocqPackages prev.rocqPackages_9_2;
  rocqPackages_9_3 = patchRocqPackages (
    mkRocqPackages prev {
      version = "9.3.0";
      hash = "sha256-Wr9+5Mq3/hS3gnyZDnzBo9aJCjeqQDGi4eaU1LinwaE=";
    }
  );
}
