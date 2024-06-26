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
      fzf
      wget
      htop
      jq
      ripgrep
      tree
      watch

      nodePackages.typescript
      nodejs
    ] ++ (lib.optionals isDarwin [
      tailscale
    ]) ++ (lib.optionals (isLinux && !isWSL) [
      telegram-desktop
      spotify
      transmission_4-gtk

      vscode

      # For work
      slack
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
        k = "kubectl";
      } // (if isLinux then {
        pbcopy = "xclip";
        pbpaste = "xclip -o";
      } else {});
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ".." = "cd ..";
        ls = "ls --color=auto -F";
        ll = "ls -lha --color=auto -F";
        k = "kubectl";
      } // (if isLinux then {
        pbcopy = "xclip";
        pbpaste = "xclip -o";
      } else {});

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
    };

    programs.git = {
      enable = true;
      userName = "Diogo Correia";
      userEmail = "dv_correia@hotmail.com";
      ignores = [ "**/.vscode/settings.json" "**/.direnv/" "**/.venv/" "**/venv/" "**/.DS_Store" ];

      lfs.enable = true;

      extraConfig = {
        branch.autosetuprebase = "always"; # rebase on git pull
        color.ui = true;
        github.user = "dvcorreia";
        push.default = "upstream"; # push the current branch to its upstream branch
        push.autoSetupRemote = true; # sets up new branch to track remote branch with same name
        init.defaultBranch = "main";
        core.editor = "nvim";
        url."git@github.com:".insteadOf = "https://github.com/";
      };

      includes = [
        {
          condition = "gitdir:~/Desktop/metacell/";
          contentSuffix = "metacell";
          contents = {
            user = {
              email = "diogo@metacell.us";
              name = "Diogo Correia";
            };
          };
        }
      ];
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.go.enable = true;

    programs.kitty = {
      enable = !isWSL;
      theme = "GitHub Dark";
      shellIntegration.enableZshIntegration = true;

      keybindings = {
        # Clipboard
        "ctrl+v" = "paste_from_clipboard";
        "ctrl+c" = "copy_or_interrupt";

        # Miscellaneous
        "ctrl+plus" = "increase_font_size";
        "ctrl+minus" = "decrease_font_size";
        "ctrl+0" = "restore_font_size";
      };
    };

    programs.neovim = {
      enable = true;

      extraLuaConfig = ''
        vim.opt.number = true
        vim.opt.relativenumber = true
      '';
    };

    programs.chromium = {
      enable = isLinux && !isWSL;

      dictionaries = [ pkgs.hunspellDictsChromium.en_US ];

      extensions = [
        { id = "gcbommkclmclpchllfjekcdonpmejbdp"; } # https everywhere
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
        { id = "fmkadmapgofadopljbjfkapdkoienihi"; } # react developer tools
        { id = "lmhkpmbekcpmknklioeibfkpmmfibljd"; } # redux devtools
      ];
    };
}
