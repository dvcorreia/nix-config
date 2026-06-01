{ pkgs, ... }:

{
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

    initLua = ''
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
}
