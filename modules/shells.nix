{
  pkgs,
  ...
}:

{
  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];
}
