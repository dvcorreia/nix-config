{
  config,
  lib,
  pkgs,
  inputs,
  currentSystem,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;

  shellAliases = {
    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gp = "git push";
    gs = "git status";
    gd = "git diff";
    gds = "git diff --staged";

    ls = "ls --color=auto -F";
    ll = "ls -lha --color=auto -F";
    k = "kubectl";
    cat = "bat";
  };

  dotAliases = import (inputs.self + "/lib/dotaliases.nix") { };
in
{
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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = shellAliases // dotAliases;

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
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

  programs.ghostty = {
    enable = currentSystem != "aarch64-linux";

    package = if !pkgs.stdenv.isDarwin then pkgs.unstable.ghostty else null;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      theme = "Github Dark Default";
      font-thicken = pkgs.stdenv.isDarwin;
      window-padding-x = 8;
      window-padding-y = 4;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-decoration = "auto";
      window-theme = "system";

      # just don't like the graphical indication
      macos-secure-input-indication = false;
    };
  };

  programs.git = {
    enable = true;

    ignores = [
      "**/.vscode/settings.json"
      "**/.direnv/"
      "**/.venv/"
      "**/venv/"
      "**/.DS_Store"
    ];

    lfs.enable = true;

    settings = {
      user = {
        name = "Diogo Correia";
        email = "dv_correia@hotmail.com";
      };
      branch.autosetuprebase = "always"; # rebase on git pull
      color.ui = true;
      github.user = "dvcorreia";
      push.default = "upstream"; # push the current branch to its upstream branch
      push.autoSetupRemote = true; # sets up new branch to track remote branch with same name
      init.defaultBranch = "main";
      core.editor = "nvim";
      core.autocrlf = "input";
      url."git@github.com:".insteadOf = "https://github.com/";
    };

    includes = [
      {
        condition = "gitdir:~/siemens/";
        contentSuffix = "siemens";
        contents = {
          user = {
            email = "diogo.correia@siemens.com";
            name = "Diogo Correia";
          };
        };
      }
    ];
  };

  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (
        p: with p; [
          bash
          c
          diff
          html
          markdown
          markdown_inline
          query
          vim
          vimdoc

          go
          nix
          python
          javascript
          typescript
        ]
      ))
    ];

    extraLuaConfig = ''
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '

      vim.opt.number = true
      vim.opt.relativenumber = true

      -- Share clipboard between OS and Neovim.
      vim.opt.clipboard = 'unnamedplus'

      vim.opt.breakindent = true

      -- Save undo history.
      vim.opt.undofile = true

      -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term.
      vim.opt.ignorecase = true
      vim.opt.smartcase = true

      -- Minimal number of screen lines to keep above and below the cursor.
      vim.opt.scrolloff = 10

      -- Set highlight on search, but clear on pressing <Esc> in normal mode
      vim.opt.hlsearch = true
      vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
    '';
  };

  programs.vscode = {
    enable = true;

    profiles.default = {
      extensions =
        with pkgs.vscode-extensions;
        [
          bbenoist.nix
          golang.go
          ms-python.python
          ms-python.vscode-pylance
          tsandall.opa
          editorconfig.editorconfig
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-styra";
            publisher = "styra";
            version = "2.1.0";
            sha256 = "sha256-WBMBj0ZBHVf6wDuXoNgkvDdDZZZLtaRipydmO7x9DP4=";
          }
        ];

      userSettings = {
        # default fonts
        "editor.fontFamily" = lib.concatStringsSep ", " [
          "Menlo"
          "Monaco"
          "'Courier New'"
          "monospace"
        ];
        "search.exclude" = {
          ".direnv" = true;
        };
        "workbench.startupEditor" = "none";
        "workbench.sideBar.location" = "right";
        "[nix]"."editor.tabSize" = 2;
      };
    };
  };
}
