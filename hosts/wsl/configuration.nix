{
  currentSystemUser,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../nixos-shared.nix
  ];

  networking.hostName = "wsl";

  wsl = {
    enable = true;
    defaultUser = currentSystemUser;
  };
}
