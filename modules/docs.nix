{
  lib,
  runCommand,
  nixosOptionsDoc,
  mdformat,
  ...
}:

let
  inherit (builtins) attrValues;
  modules = import ./. { inherit lib; };

  mkOptionsDoc =
    modules:
    let
      eval = lib.evalModules {
        modules = modules ++ [
          { _module.check = false; }
        ];
      };
    in
    nixosOptionsDoc {
      inherit (eval) options;
    };

  nixosDoc = mkOptionsDoc (attrValues modules.nixosModules);
  darwinDoc = mkOptionsDoc (attrValues modules.darwinModules);
in
runCommand "module-options" { } ''
  mkdir -p $out

  cat ${nixosDoc.optionsCommonMark} | ${mdformat}/bin/mdformat - > $out/nixos-options.md
  cat ${darwinDoc.optionsCommonMark} | ${mdformat}/bin/mdformat - > $out/darwin-options.md
''
