{
  nixpkgs,
  inputs,
}:

let
  syslib = import ./lib/systems.nix { inherit nixpkgs; };
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
  inherit mkHome;

  # Generate home configs for all systems with user@system format
  allSystems =
    user:
    {
      isWSL ? false,
    }:
    nixpkgs.lib.mapAttrs' (system: config: {
      name = "${user}@${system}";
      value = config;
    }) (forAllSystems (system: mkHome user { inherit system isWSL; }));
}
