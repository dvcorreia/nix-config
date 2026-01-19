{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
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

    agenix-shell.url = "github:aciceri/agenix-shell";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    dvcorreia-website.url = "github:dvcorreia/dvcorreia.com";
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
      inherit (self) outputs;

      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.packages
            self.overlays.unstable-packages
          ];
        }
      );

      sshKeys = import ./secrets/ssh-keys.nix;
    in
    {
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      overlays = {
        packages = final: _prev: import ./pkgs final.pkgs;

        # when applied, the unstable nixpkgs set will
        # be accessible through 'pkgs.unstable'
        unstable-packages = final: _prev: {
          unstable = import inputs.nixpkgs-unstable {
            system = final.system;
          };
        };
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      inherit sshKeys;

      darwinConfigurations.macbook-m3-pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/macbook-m3-pro/configuration.nix
        ];
        specialArgs = {
          inherit inputs outputs;
        };
      };

      nixosConfigurations.sines = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/sines/configuration.nix
        ];
        specialArgs = {
          inherit inputs outputs;
        };
      };

      nixosConfigurations.proart-7950x = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/proart-7950x/configuration.nix
        ];
        specialArgs = {
          inherit inputs outputs;
        };
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              gnumake
              agenix.packages.${system}.default
              nixos-rebuild
            ];
          };

          infra = import ./shells/infra.nix {
            inherit pkgs system inputs;
          };
        }
      );

    };
}
