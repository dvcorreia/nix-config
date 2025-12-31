{ lib }:
let
  moduleLib = import ../lib/modules.nix { inherit lib; };
  inherit (moduleLib) generateModulesAuto;
in

{
  nixosModules = generateModulesAuto ./nixos;
  darwinModules = generateModulesAuto ./darwin;
}
