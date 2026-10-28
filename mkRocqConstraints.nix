pkgs: pkgName:

with pkgs.rocqPackages.lib;
let
  rocqVersions =
    let
      rocqVersions = map (attr: pkgs.${attr}.rocq-core.version) (
        filter (hasPrefix "rocqPackages_") (attrNames pkgs)
      );
    in
    pkgs.rocqPackages.overrideScope (
      final: prev: {
        lib = prev.lib // {
          switch = dependencies: cases: _: { inherit cases dependencies; };
          mkCase = version: clause: { inherit version clause; };
        };

        mkRocqDerivation = import ./mkRocqDerivation.nix { inherit final prev; };

        rocq-core = (prev.rocq-core.override { rocq-version = "rocq"; }) // {
          availableVersions =
            let
              mkClause = v: { rocq, ... }: versions.isEq rocq v;
            in
            map (v: final.lib.mkCase v (mkClause v)) rocqVersions;
        };
      }
    );

  rawMatrix =
    let
      dependencies = rocqVersions.${pkgName}.rocqDependencies;
      extractVersions = { pname, availableVersions, ... }: nameValuePair pname availableVersions;
    in
    cartesianProduct (listToAttrs (map extractVersions dependencies));

  buildConstraints =
    let
      init = {
        constraints = { };
        clauses = (_: true);
      };

      merge =
        { constraints, clauses }:
        { name, value }:
        {
          constraints = constraints // {
            ${name} = value.version;
          };
          clauses = (attrs: clauses attrs && value.clause attrs);
        };
    in
    map (elem: foldl' merge init (attrsToList elem));

  finalMatrix = map ({ constraints, ... }: constraints) (
    filter ({ clauses, constraints }: clauses constraints) (buildConstraints rawMatrix)
  );
in
finalMatrix
