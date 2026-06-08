{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
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
      agenix-shell,
      deploy-rs,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      overlays = {
        packages = final: _prev: import ./pkgs final.pkgs;

        # when applied, the unstable nixpkgs set will
        # be accessible through 'pkgs.unstable'
        unstable-packages = final: _prev: {
          unstable = import nixpkgs-unstable {
            system = final.stdenv.hostPlatform.system;
          };
        };

        patches = import ./overlays/patches.nix;
      };

      inherit (import ./modules) nixosModules darwinModules homeManagerModules;

      darwinConfigurations.macbook-m3-pro = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/macbook-m3-pro/configuration.nix
        ];
        specialArgs = {
          inherit inputs;
        };
      };

      nixosConfigurations.sines = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/sines/configuration.nix
        ];
        specialArgs = {
          inherit inputs;
        };
      };

      nixosConfigurations.proart-7950x = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/proart-7950x/configuration.nix
        ];
        specialArgs = {
          inherit inputs;
        };
      };

      deploy.nodes = {
        sines = {
          hostname = "sines.dvcorreia.loc";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.sines;
          };
        };

        proart-7950x = {
          hostname = "proart-7950x.dvcorreia.loc";
          remoteBuild = true;
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.proart-7950x;
          };
        };
      };

      checks =
        let
          nixpkgsFor = forAllSystems (
            system:
            import nixpkgs {
              inherit system;
              overlays = [
                self.overlays.packages
                self.overlays.unstable-packages
                self.overlays.patches
              ];
            }
          );
          testChecks = import ./tests { inherit nixpkgsFor inputs; };
          deployChecks = builtins.mapAttrs (
            system: deployLib: deployLib.deployChecks self.deploy
          ) deploy-rs.lib;
        in
        nixpkgs.lib.recursiveUpdate deployChecks testChecks;

      sshKeys = import ./secrets/ssh-keys.nix;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.agenix.overlays.default
            ];
          };
        in
        {
          default =
            let
              installationScript = agenix-shell.lib.installationScript system {
                secrets = {
                  TF_VAR_hcloud_token.file = ./secrets/hetzner-homelab-api-token.age;
                  TF_VAR_cloudflare_api_token.file = ./secrets/cloudflare-dns-token.age;
                  TF_VAR_passphrase.file = ./secrets/opentofu-encryption-key.age;
                };
              };
            in
            pkgs.mkShell {
              packages = with pkgs; [
                git
                gnumake
                openssh
                opentofu
                pkgs.agenix
                nixos-rebuild
                inputs.deploy-rs.packages.${system}.default

                opencode
                terraform-mcp-server
              ];

              shellHook = ''
                source ${pkgs.lib.getExe installationScript}
              '';

              TF_VAR_ssh_pub_key = self.sshKeys.yubikey1-ed25519-sk;
              TF_VAR_cloudflare_account_id = "35db5f9742873a380407761666ef726b";
            };
        }
      );
    };
}
