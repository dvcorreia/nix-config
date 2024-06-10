{ isWSL, inputs, ... }:

{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
    # The state version is required and should stay at the version you
    # originally installed. DO NOT CHANGE!
    home.stateVersion = "24.05";

    xdg.enable = true;

    # Packages I always want installed. Most packages I install using
    # per-project flakes sourced with direnv and nix-shell, so this is
    # not a huge list.
    home.packages = with pkgs; [
      wget
      htop
      jq
      ripgrep
      tree
      watch

      nodePackages.typescript
      nodejs
    ] ++ (lib.optionals isDarwin [

    ]) ++ (lib.optionals (isLinux && !isWSL) [
      chromium
    ]);

    #---------------------------------------------------------------------
    # Env vars and dotfiles
    #---------------------------------------------------------------------
    home.sessionVariables = {
      EDITOR = "nvim";
    };

    #---------------------------------------------------------------------
    # Programs
    #---------------------------------------------------------------------

    programs.bash = {
      enable = true;
      shellOptions = [];
      historyControl = [ "ignoredups" "ignorespace" ];

      shellAliases = {
        ls = "ls --color=auto -F";
        ll = "ls -lha --color=auto -F";
      };
    };

    programs.zsh = {
      enable = true;

      shellAliases = {
        ".." = "cd ..";
        ls = "ls --color=auto -F";
        ll = "ls -lha --color=auto -F";
      };
    };

    programs.git = {
      enable = true;
      userName = "Diogo Correia";
      userEmail = "dv_correia@hotmail.com";

      extraConfig = {
        branch.autosetuprebase = "always"; # rebase on git pull
        color.ui = true;
        github.user = "dvcorreia";
        push.default = "upstream"; # push the current branch to its upstream branch
        init.defaultBranch = "main";
      };
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.go.enable = true;

    programs.kitty = {
      enable = !isWSL;
    };

    programs.neovim = {
      enable = true;
    };
}
