{
  config,
  lib,
  pkgs,
  ...
}:

let
  sshKeys = import ../../secrets/ssh-keys.nix { };
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.loader.grub.enable = true;

  networking.hostName = "sines";

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
      options = "--delete-older-than 7d";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    sshKeys.dvcorreia
  ];
  users.users.dvcorreia = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialHashedPassword = "$y$j9T$2DyEjQxPoIjTkt8zCoWl.0$3mHxH.fqkCgu53xa0vannyu4Cue3Q7xL4CrUhMxREKC"; # Password.123

    openssh.authorizedKeys.keys = [
      sshKeys.dvcorreia
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # Enable tailscale. I manually authenticate when we want
  # with "sudo tailscale up".
  services.tailscale.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  system.stateVersion = "24.11";
}
