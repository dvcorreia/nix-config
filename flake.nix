{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      darwin,
      agenix,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      # helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # nixpkgs instantiated for supported system types
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      # function to create a nixos or darwin system
      mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs; };

      # function to create home manager configurations from other distros
      mkHome = import ./lib/mkhome.nix { inherit nixpkgs inputs; };
    in
    {
      nixosModules = import ./modules { lib = nixpkgs.lib; };

      nixosConfigurations."proart-7950x" = mkSystem "proart-7950x" rec {
        system = "x86_64-linux";
        user = "dvcorreia";
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
        modules = [
          agenix.nixosModules.default
        ];
      };

      nixosConfigurations.wsl = mkSystem "wsl" {
        system = "x86_64-linux";
        user = "dvcorreia";
        wsl = true;
      };

      packages = forAllSystems (system: {
        docs = (nixpkgsFor.${system}).callPackage ./modules/docs.nix { };
        homeConfigurations = {
          dvcorreia = mkHome "dvcorreia" { inherit system; };
          "dvcorreia@wsl" = mkHome "dvcorreia@wsl" {
            inherit system;
            isWSL = true;
          };
        };
      });

      lib = {
        inherit mkSystem mkHome;
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              gnumake
              agenix.packages.${system}.default
            ];
          };
        }
      );

      formatter = forAllSystems (system: (nixpkgsFor.${system}).nixfmt-tree);
    };
}
