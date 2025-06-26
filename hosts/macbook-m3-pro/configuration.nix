{
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (inputs.self) nixosModules;
in
{
  imports = [
    nixosModules.nix
    nixosModules.shells
    nixosModules.darwin-dock
    nixosModules.darwin-system
    nixosModules.darwin-wallpaper
  ];
}

