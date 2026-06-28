{ ... }:

{
  system.defaults = {
    menuExtraClock.Show24Hour = true;

    controlcenter = {
      Sound = true;
      Bluetooth = true;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      mru-spaces = false;
      orientation = "bottom";
      showhidden = true;
      tilesize = 44;
      mineffect = "scale";
      show-recents = false;
      wvous-tl-corner = 2;
      wvous-tr-corner = 1;
      wvous-bl-corner = 3;
      wvous-br-corner = 4;
    };

    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      ShowStatusBar = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "Nlsv";
    };

    trackpad = {
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };

    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = true;
      AppleInterfaceStyle = "Dark";
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 3;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleAccentColor = "-1";
        AppleHighlightColor = "0.847059 0.847059 0.862745 Graphite";
      };

      "com.apple.frameworks.diskimages" = {
        "auto-open-ro-root" = true;
        "auto-open-rw-root" = true;
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "com.apple.finder".WarnOnEmptyTrash = false;
      "com.apple.finder".OpenWindowForNewRemovableDisk = true;
    };

    screencapture = {
      location = "~/Desktop";
      type = "png";
      disable-shadow = true;
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };
  };
}
