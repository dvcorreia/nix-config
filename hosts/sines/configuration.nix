{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./acme.nix
    ./websites
    ./pocket-id.nix
    ./prometheus.nix
    ./grafana.nix
    ./headscale
    ../../modules/nix.nix
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
  ];

  boot.loader.grub.enable = true;

  networking.hostName = "sines";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnumake
    git
    ghostty # for the 'xterm-ghostty': unknown terminal type
  ];

  users.users =
    let
      inherit (inputs.self) sshKeys;
    in
    {
      root.openssh.authorizedKeys.keys = with sshKeys; [
        dvcorreia
        yubikey1-ed25519-sk
      ];

      dvcorreia = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];

        openssh.authorizedKeys.keys = with sshKeys; [
          dvcorreia
          yubikey1-ed25519-sk
        ];
      };
    };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  system.stateVersion = "24.11";
}
