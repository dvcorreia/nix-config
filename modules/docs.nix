{
  lib,
  runCommand,
  nixosOptionsDoc,
  ...
}:

let
  moduleLib = import ../lib/modules.nix { inherit lib; };
  inherit (moduleLib) generateModulesAuto;

  modules = builtins.attrValues (generateModulesAuto ./.);

  eval = lib.evalModules {
    modules = modules ++ [
      { _module.check = false; }
    ];
  };

  optionsDoc = nixosOptionsDoc {
    inherit (eval) options;
  };

in
runCommand "module-options.md" { } ''
  cat ${optionsDoc.optionsCommonMark} >> $out
''
