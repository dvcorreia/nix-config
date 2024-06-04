{ config, pkgs, ... }:
{
  # We install Nix using a separate installer so we don't want nix-darwin
  # to manage it for us. This tells nix-darwin to just use whatever is running.
  nix.useDaemon = true;

  nix = {
    # We need to enable flakes
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-platforms = x86_64-darwin
    '';

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;
  programs.fish.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  system = {
    defaults = {
      NSGlobalDomain = {
        NSAutomaticWindowAnimationsEnabled = false;
      };

      dock = {
        autohide = false;
        mru-spaces = false;
        orientation = "bottom";
        showhidden = true;
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

      CustomUserPreferences = {
        "com.apple.finder" = {
          WarnOnEmptyTrash = false;
          OpenWindowForNewRemovableDisk = true;
        };

        "com.apple.frameworks.diskimages" = {
          # automatically open a new Finder window when a volume is mounted
          auto-open-ro-root = true;
          auto-open-rw-root = true;
        };

        "com.apple.desktopservices" = {
          # avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
    };
  };
}
