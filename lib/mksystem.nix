{
  nixpkgs,
  inputs,
  overlays ? [ ],
}:

name:
{
  system,
  user,
  darwin ? false,
  modules ? [ ],
  includeHomeManager ? true,
  wsl ? false,
}:
let
  isWSL = wsl;

  hostConfig = ../hosts/${name}/configuration.nix;
  userOSConfig = if darwin then ../users/${user}/darwin.nix else ../users/${user}/nixos.nix;
  userHomeManagerConfig = ../users/${user}/home-manager.nix;

  mkSystem = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  homeManagerModule =
    if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  sshKeys = import ../secrets/ssh-keys.nix { };

  specialArgs = {
    inherit inputs sshKeys;
    currentSystem = system;
    currentSystemName = name;
    currentSystemUSer = user;
  };

  isAarch64 = builtins.match "aarch64-.*" system != null;
in
mkSystem {
  inherit system specialArgs;

  modules =
    [
      # define overlays first so they are available globally
      { nixpkgs.overlays = overlays; }
      { nixpkgs.config.allowUnfree = true; }

      (if isWSL then inputs.nixos-wsl.nixosModules.wsl else {})

      # nix-darwin seems to need this
      (if darwin then { system.stateVersion = 5; } else { })

      # hostname is the name of the system by default
      { networking.hostName = name; }

      hostConfig
      userOSConfig

      # we expose some extra arguments so that our modules can parameterize
      # better based on these values.
      {
        config._module.args = {
          currentSystem = system;
          currentSystemName = name;
          currentSystemUser = user;
          isWSL = isWSL;
          inputs = inputs;
        };
      }
    ]
    ++ (
      if darwin then
        [
          inputs.nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = isAarch64;
              mutableTaps = true;
              user = "${user}";
              taps = with inputs; {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };
            };
          }
        ]
      else
        [ ]
    )
    ++ (
      if includeHomeManager then
        [
          homeManagerModule.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${user} = import userHomeManagerConfig { inherit inputs isWSL; };
            };
          }
        ]
      else
        [ ]
    )
    ++ modules;
}
