{ isWSL, inputs, ... }:

{
  currentSystem,
  currentSystemUser,
  config,
  lib,
  pkgs,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  inherit (inputs.self) nixosModules;

  ghosttyPackage = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    nixosModules.home-vscode
    nixosModules.home-shells
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
    username = currentSystemUser;
    homeDirectory = if isDarwin then "/Users/${currentSystemUser}" else "/home/${currentSystemUser}";

    # The state version is required and should stay at the version you
    # originally installed. DO NOT CHANGE!
    stateVersion = "24.05";
  };

  xdg.enable = true;

  services.ssh-agent.enable = isWSL;

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages =
    with pkgs;
    [
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
    ]
    ++ (lib.optionals isDarwin [ ])
    ++ (
      lib.optionals (isLinux && !isWSL) [
        telegram-desktop
        transmission_4-gtk
        stremio
      ]
      ++ (lib.optionals (currentSystem != "aarch64-linux") [
        spotify
      ])
    );

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.bash.enable = true;
  programs.zsh.enable = true;

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

  programs.git = {
    enable = true;
    userName = "Diogo Correia";
    userEmail = "dv_correia@hotmail.com";
    ignores = [
      "**/.vscode/settings.json"
      "**/.direnv/"
      "**/.venv/"
      "**/venv/"
      "**/.DS_Store"
    ];

    lfs.enable = true;

    extraConfig = {
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.go.enable = true;

  programs.kitty = {
    enable = isLinux && !isWSL;
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

  programs.ghostty = {
    enable = !isWSL && (currentSystem != "aarch64-linux");

    package = if isLinux then ghosttyPackage else null;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      theme = "Github-Dark-Default";
      font-thicken = isDarwin;
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

  programs.vscode.enable = !isWSL;
}
