{ final, prev }:

with final.lib;
fix (
  self:
  {
    defaultVersion ? "dev",
    pname,
    propagatedBuildInputs ? [ ],
    version,
    ...
  }@args:
  let
    applyOverride = f: self (args // (if isFunction f then f args else f));
    this = self args;
  in
  {
    inherit defaultVersion pname;
    inherit propagatedBuildInputs;

    override = applyOverride;
    overrideAttrs = applyOverride;

    # 'lib.switch' expects to recieve the version, using the 'version' field.
    # As we would like to retrieve the name instead, we overwrite this field.
    version = pname;

    # Get the transitive Rocq dependency closure
    rocqDependencies =
      let
        isRocqDerivation = hasAttr "rocqDependencies";

        collectRocqDepsOf =
          {
            propagatedBuildInputs ? [ ],
            ...
          }@drv:
          (if isRocqDerivation drv then [ drv ] else [ ])
          ++ concatMap collectRocqDepsOf (filter isRocqDerivation propagatedBuildInputs);
      in
      unique (
        [
          final.rocq-core
          this
        ]
        ++ concatMap collectRocqDepsOf propagatedBuildInputs
      );
  }
  // (
    if isAttrs defaultVersion && hasAttr "cases" defaultVersion then
      {
        availableVersions =
          let
            mkVersion =
              { out, case }:
              let
                caseFixed = if builtins.typeOf case == "string" then versions.isEq case else case;
                clauses = flatten [ caseFixed ];
                dependencies = flatten [ defaultVersion.dependencies ];

                clause =
                  attrs:
                  all id (
                    [ (versions.isEq attrs.${args.pname} out) ]
                    ++ (zipListsWith (cl: pname: cl attrs.${pname}) clauses dependencies)
                  );
              in
              mkCase out clause;
          in
          map mkVersion defaultVersion.cases;
      }
    else
      {
        availableVersions = [ (mkCase defaultVersion (_: true)) ];
      }
  )
)
