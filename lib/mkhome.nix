{
  nixpkgs,
  inputs,
}:

user:
{
  system,
  isWSL ? false,
}:

let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  userHomeManagerConfig = ../users/${user}/home-manager.nix;
  sshKeys = import ../secrets/ssh-keys.nix;

  specialArgs = {
    inherit inputs sshKeys;
    currentSystem = system;
    currentSystemUser = user;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    { programs.home-manager.enable = true; }
    (import userHomeManagerConfig { inherit inputs isWSL; })
  ];

  extraSpecialArgs = specialArgs;
}
