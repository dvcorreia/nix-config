{ inputs, pkgs, ... }:

{
  homebrew = {
    enable = true;
    casks  = [
      "telegram"
      "transmission"
      "vlc"
      "discord"
      "chromium"
      "istat-menus"
      "rectangle"
      "spotify"
    ];
  };

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.dvcorreia = {
    home = "/Users/dvcorreia";
    shell = pkgs.fish;
  };
}