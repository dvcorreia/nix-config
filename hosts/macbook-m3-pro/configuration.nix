{
  inputs,
  pkgs,
  ...
}:

let
  currentSystem = "aarch64-darwin";
in
{
  imports = [
    ../../modules/nix.nix
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.home-manager.darwinModules.home-manager
  ];

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.dvcorreia = {
    home = "/Users/dvcorreia";
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = inputs.self.sshKeys.users;
  };

  system.primaryUser = "dvcorreia";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs currentSystem; };
    users.dvcorreia = import ../../users/dvcorreia;
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

  nixpkgs = {
    overlays = [
      inputs.self.overlays.unstable-packages
    ];
    config = {
      allowUnfreePredicate =
        pkg:
        builtins.elem (pkg.pname) [
          "vscode"
          "vscode-extension-MS-python-vscode-pylance"
        ];
    };
    hostPlatform.system = currentSystem;
  };

  system.defaults = {
    # show 24 hour clock
    menuExtraClock.Show24Hour = true;

    # show sound and bluetooth icon in menubar
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

  nix-homebrew =
    let
      isAarch64 = builtins.match "aarch64-.*" currentSystem != null;
    in
    {
      enable = true;
      enableRosetta = isAarch64;
      mutableTaps = true;
      user = "dvcorreia";
      taps = with inputs; {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
      };
    };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      "homebrew/core"
      "homebrew/cask"
    ];
    brews = [
      "cookcli"
    ];
    casks = [
      "ghostty"
      "google-chrome"
      "brave-browser"
      "telegram"
      "transmission"
      "vlc"
      "stremio"
      "discord"
      "rectangle"
      "spotify"
      "stats"
      "netnewswire"
      "pika"
      "reminders-menubar"
      "freecad"
      "kicad"
      "docker-desktop"
      "signal"
      "jordanbaird-ice" # menu bar management tool
    ];

    # MAS apps must have been installed or bought before on your Apple ID
    masApps = {
      Tailscale = 1475387142;
    };
  };

  environment.systemPackages = with pkgs; [
    gnumake
    openssh
    tailscale
    unstable.opencode
  ];

  fonts.packages = with pkgs; [
    monaspace
    jetbrains-mono
    mononoki
    fira
    iosevka
  ];

  system.stateVersion = 5;
}
