{
  config,
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  imports = [
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./neovim.nix
    ./vscode.nix
    ./zsh.nix
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  home = {
    username = "dvcorreia";
    homeDirectory = if isDarwin then "/Users/dvcorreia" else "/home/dvcorreia";

    # The state version is required and should stay at the version you
    # originally installed. DO NOT CHANGE!
    stateVersion = "24.05";
  };

  xdg.enable = true;

  home.packages = with pkgs; [
    lsof # lsof -n -i :80 | grep LISTEN
    wget
    jq
    bat # cat w/ sintax highlighting
    ripgrep
    tree
    watch
    ffmpeg
    nixfmt-rfc-style
    unzip
    glow # markdown reader

    nodePackages.typescript
    nodejs
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.tmux = {
    enable = true;
  };

  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  programs.lf.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.go.enable = true;
}
