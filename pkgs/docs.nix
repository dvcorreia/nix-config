{
  lib,
  runCommand,
  nixosOptionsDoc,
  mdformat,
  ...
}:

let
  inherit (builtins) attrValues;

  nixosModules = import ../modules/nixos;
  darwinModules = import ../modules/darwin;
  homeManagerModules = import ../modules/home-manager;

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

  nixosDoc = mkOptionsDoc (attrValues nixosModules);
  darwinDoc = mkOptionsDoc (attrValues darwinModules);
  homeManagerDoc = mkOptionsDoc (attrValues homeManagerModules);
in
runCommand "module-options" { } ''
  mkdir -p $out

  cat ${nixosDoc.optionsCommonMark} | ${mdformat}/bin/mdformat - > $out/nixos-options.md
  cat ${darwinDoc.optionsCommonMark} | ${mdformat}/bin/mdformat - > $out/darwin-options.md
  cat ${homeManagerDoc.optionsCommonMark} | ${mdformat}/bin/mdformat - > $out/home-manager-options.md
''
