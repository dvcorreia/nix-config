{
  description = "Nix systems configuration by dvcorreia";

  inputs = {
    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # Build a custom WSL installer
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      ...
    }@inputs:
    let
      # Overlays is the list of overlays we want to apply from flake inputs.
      overlays = [ ];

      mkSystem = import ./lib/mksystem.nix { inherit overlays nixpkgs inputs; };
    in
    {
      nixosConfigurations.proart-7950x = mkSystem "proart-7950x" rec {
        system = "x86_64-linux";
        user   = "dvcorreia";
      };

      darwinConfigurations.macbook-pro-intel = mkSystem "macbook-pro-intel" {
        system = "x86_64-darwin";
        user = "dvcorreia";
        darwin = true;
      };

      darwinConfigurations.macbook-m3-pro = mkSystem "macbook-m3-pro" {
        system = "aarch64-darwin";
        user = "dvcorreia";
        darwin = true;
      };

      nixosConfigurations.wsl = mkSystem "wsl" {
        system = "x86_64-linux";
        user = "dvcorreia";
        wsl = true;
      };
    };
}
