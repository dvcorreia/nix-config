{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
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
      nixpkgs-stable,
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
    in
    {
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

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              agenix.packages.${system}.default
            ];
          };
        }
      );

      formatter = forAllSystems (system: (nixpkgsFor.${system}).nixfmt-tree);
    };
}
