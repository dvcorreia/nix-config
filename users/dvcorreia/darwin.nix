{ inputs, pkgs, ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
    casks = [
      "ghostty"
      "telegram"
      "visual-studio-code"
      "transmission"
      "vlc"
      "stremio"
      "discord"
      "istat-menus"
      "rectangle"
      "spotify"
      "stats"

      # work related stuff
      "google-chrome"
      "slack"
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
  };

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  environment.systemPackages = with pkgs; [
    gnumake
    openssh
  ];

  fonts.packages = [
    pkgs.monaspace
    pkgs.jetbrains-mono
    pkgs.mononoki
  ];
}
