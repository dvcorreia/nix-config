{
  nixpkgs,
  inputs,
}:

let
  syslib = import ./systems.nix { inherit nixpkgs; };
  inherit (syslib) forAllSystems;

  mkHome =
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
      sshKeys = import ../secrets/ssh-keys.nix { };

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
    };
in
{
  __functor = self: mkHome;

  # Generate user home manager configurations for all systems
  allSystems =
    user:
    {
      isWSL ? false,
    }:
    forAllSystems ( system: {
      ${user} = mkHome user { inherit system isWSL; };
    });
}
