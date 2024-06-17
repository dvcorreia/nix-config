{ inputs, pkgs, ... }:

{
  homebrew = {
    enable = true;
    casks  = [
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
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.dvcorreia = {
    home = "/Users/dvcorreia";
    shell = pkgs.zsh;
  };

  environment.shells = with pkgs; [ bashInteractive zsh ];

  fonts = {
    fontDir.enable = true;

    fonts = [
      pkgs.monaspace
      pkgs.jetbrains-mono
      pkgs.mononoki
    ];
  };
}
