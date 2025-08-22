{
  inputs,
  sshKeys,
  pkgs,
  ...
}:

{
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
      "docker"
      "signal"
    ];

    # MAS apps must have been installed or bought before on your Apple ID
    masApps = {
      Tailscale = 1475387142;
    };
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.dvcorreia = {
    home = "/Users/dvcorreia";
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = sshKeys.users;
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  environment.systemPackages = with pkgs; [
    gnumake
    openssh
  ];

  fonts.packages = with pkgs; [
    monaspace
    jetbrains-mono
    mononoki
    fira
    iosevka
  ];
}
