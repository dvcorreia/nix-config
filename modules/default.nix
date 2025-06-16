{ lib }:
let
  moduleLib = import "../lib/modules.nix";
  inherit (moduleLib) generateModulesAuto;
in
generateModulesAuto ./.
