{ config, pkgs, ... }:

{
  nix = {
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

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  # add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
  system.activationScripts.postUserActivation.text = ''
    softwareupdate --install-rosetta --agree-to-license
    # activateSettings -u will reload the settings from the database and apply them to the current session,
    # so we do not need to logout and login again to make the changes take effect.
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  system.defaults = {
    menuExtraClock.Show24Hour = true; # show 24 hour clock

    dock = {
      autohide = false;
      mru-spaces = false;
      orientation = "bottom";
      showhidden = true;
      tilesize = 44;
      mineffect = "scale";
      persistent-apps = [
        "/Applications/Safari.app"
        "/Applications/Google Chrome.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Reminders.app"
        "/System/Applications/Notes.app"
        "/Applications/NetNewsWire.app"
        "/Applications/Spotify.app"
        "/Applications/Telegram.app"
        "/Applications/Discord.app"
      ];
      show-recents = false;

      wvous-tl-corner = 2; # top-left - Mission Control
      wvous-tr-corner = 1; # top-right - Does nothing (13 for Lock Screen)
      wvous-bl-corner = 3; # bottom-left - Application Windows
      wvous-br-corner = 4; # bottom-right - Desktop
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

    trackpad = {
      TrackpadRightClick = true; # enable two finger right click
      TrackpadThreeFingerDrag = false; # disable three finger drag
    };

    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = true; # enable natural scrolling(default to true)
      AppleInterfaceStyle = "Dark"; # dark mode
      AppleKeyboardUIMode = 3; # mode 3 enables full keyboard control.
      ApplePressAndHoldEnabled = false; # enable key repetition

      # sets how long it takes before it starts repeating.
      InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
      # sets how fast it repeats once it starts.
      KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

      NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
      NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
      NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
      NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
      NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
      NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

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
      "com.apple.finder".OpenWindowForNewRemovableDisk = true; # TODO: not working!
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
