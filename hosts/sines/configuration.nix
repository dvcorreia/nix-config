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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnumake
    git
  ];

  users.users =
    let
      sshKeys = import ../../secrets/ssh-keys.nix { };
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

  services.nginx = {
    enable = true;

    virtualHosts."saraclara.com" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        return = ''200 '<img src="https://gifsec.com/wp-content/uploads/2022/09/middle-finger-gif-3.gif" />' '';
        extraConfig = ''
          default_type text/html;
        '';
      };
    };

    virtualHosts."dvcorreia.com" = {
      addSSL = true;
      enableACME = true;

      root = "${inputs.dvcorreia-website.packages.${pkgs.system}.default}/share/dvcorreia-website";

      locations."/" = {
        index = "index.html";
        tryFiles = "$uri $uri/ =404";
        extraConfig = ''
          error_page 404 /404.html;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "dv_correia@hotmail.com";
  };

  system.stateVersion = "24.11";
}
