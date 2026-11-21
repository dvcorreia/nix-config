{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./storage.nix
    ./samba.nix
    ./tailscale.nix
    ./prometheus.nix
    ../../modules/nix.nix
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nas";
    useDHCP = lib.mkDefault true;
  };

  # nas.local resolution on the LAN (mDNS)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.smartd.enable = true;

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    git
    ghostty # for the 'xterm-ghostty': unknown terminal type
    smartmontools
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

  system.stateVersion = "26.05";
}
