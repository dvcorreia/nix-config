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
}
