{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    networkmanager.enable = true;
    hostName = "proart-7950x";
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [ "dvcorreia" ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 120d";
    };
  };

  users.users =
    let
      sshKeys = import ../../secrets/ssh-keys.nix;
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

  time.timeZone = "Europe/Lisbon";

  console.keyMap = "pt-latin1";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "pt_PT.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_MEASUREMENT = "pt_PT.UTF-8";
      LC_MONETARY = "pt_PT.UTF-8";
      LC_TIME = "pt_PT.UTF-8";
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
