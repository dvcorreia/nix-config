{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ../../modules/nix.nix
    inputs.agenix.nixosModules.default
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  networking = {
    hostName = "rpi3b-home";
    useDHCP = lib.mkDefault true;
  };

  hardware.enableRedistributableFirmware = true;

  # uncompressed image so it can be flashed with `dd`
  sdImage.compressImage = false;

  # rpi3b-home.local resolution on the LAN (mDNS)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  environment.systemPackages = with pkgs; [
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

  system.stateVersion = "25.11";
}
