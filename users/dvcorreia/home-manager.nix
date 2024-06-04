{ isWSL, inputs, ... }:

{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
    # The state version is required and should stay at the version you
    # originally installed. DO NOT CHANGE!
    home.stateVersion = "24.05";

    # Packages I always want installed. Most packages I install using
    # per-project flakes sourced with direnv and nix-shell, so this is
    # not a huge list.
    home.packages = [
      pkgs.wget
      pkgs.htop
      pkgs.jq
      pkgs.ripgrep
      pkgs.tree
      pkgs.watch
    ];

    #---------------------------------------------------------------------
    # Programs
    #---------------------------------------------------------------------

    programs.bash = {
      enable = true;
      shellOptions = [];
      historyControl = [ "ignoredups" "ignorespace" ];

      shellAliases = {
        ls = "ls --color=auto -F";
      };
    };

    programs.git = {
      enable = true;
      userName = "Diogo Correia";
      userEmail = "dv_correia@hotmail.com";

      extraConfig = {
        color.ui = true;
        github.user = "dvcorreia";
        init.defaultBranch = "main";
      };
    };

    programs.direnv.enable = true;

    programs.fish = {
      enable = true;

      shellAliases = {
        ls = "ls --color=auto -F";
      };
    };
}