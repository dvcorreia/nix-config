{ config, pkgs, ... }:
{
  # We install Nix using a separate installer so we don't want nix-darwin
  # to manage it for us. This tells nix-darwin to just use whatever is running.
  nix.useDaemon = true;

  nix = {
    # We need to enable flakes
    extraOptions = ''
      auto-optimise-store = false # not true because of https://github.com/NixOS/nix/issues/7273
      experimental-features = nix-command flakes
      extra-platforms = x86_64-darwin
      sandbox = true
    '';

    gc = {
      # user = "root";
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  # # networking.hosts not supported on nix darwin (see: PR #939 and #807)
  # environment.etc."hosts" = {
  #   enable = true;
  #   text = ''
  #     ##
  #     # Host Database
  #     #
  #     # localhost is used to configure the loopback interface
  #     # when the system is booting. Do not change this entry.
  #     ##
  #     127.0.0.1	localhost
  #     255.255.255.255	broadcasthost
  #     ::1             localhost

  #     # proart-7950x tailscale IP
  #     100.96.133.89 proart-7950x.local
  #   '';
  # };

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  system.defaults = {
    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleAccentColor = "-1"; # Graphite
        AppleHighlightColor = "0.847059 0.847059 0.862745 Graphite";
      };

      "com.apple.frameworks.diskimages" = {
        # automatically open a new Finder window when a volume is mounted
        "auto-open-ro-root" = true;
        "auto-open-rw-root" = true;
      };

      "com.apple.desktopservices" = {
        # avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "com.apple.finder".WarnOnEmptyTrash = false;
      "com.apple.finder".OpenWindowForNewRemovableDisk = true; # not working!
    };

    dock = {
      autohide = false;
      mru-spaces = false;
      orientation = "bottom";
      showhidden = true;
      tilesize = 44;
      mineffect = "scale";
      # persistent-apps = [
      #   ""
      # ];
      show-recents = false;
    };

    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      ShowStatusBar = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
      FXDefaultSearchScope = "SCcf"; # when performing a search, search the current folder by default
      FXPreferredViewStyle = "Nlsv"; # use list view in all Finder windows by default
    };

    screencapture = {
      location = "~/Desktop";
      type = "png";
      disable-shadow = true;
    };

    screensaver = {
      # require password immediately after sleep or screen saver begins
      askForPassword = true;
      askForPasswordDelay = 0;
    };
  };
}
