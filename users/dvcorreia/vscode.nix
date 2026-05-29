{ lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

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
          astro-build.astro-vscode
          hashicorp.terraform
          myriad-dreamin.tinymist
          svelte.svelte-vscode
          tamasfe.even-better-toml
          unifiedjs.vscode-mdx
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-styra";
            publisher = "styra";
            version = "2.1.0";
            sha256 = "sha256-WBMBj0ZBHVf6wDuXoNgkvDdDZZZLtaRipydmO7x9DP4=";
          }
          {
            name = "pierre-theme";
            publisher = "pierrecomputer";
            version = "1.0.3";
            sha256 = "sha256-NI7wxBu8xFoepgY6bc85ofLOjg0F9gthmT1LJm8ZcJk=";
          }
          {
            name = "pierre-vscode-icons";
            publisher = "pierrecomputer";
            version = "0.0.9";
            sha256 = "sha256-m2bWwKllNQ4+aG7nUHCd+7LTXgQ0QmSBZxHvG3I3i2A=";
          }
        ];

      userSettings = {
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
        "window.autoDetectColorScheme" = true;
        "workbench.preferredDarkColorTheme" = "Pierre Dark";
        "workbench.preferredLightColorTheme" = "Pierre Light";
        "workbench.iconTheme" = "pierre-icons-complete";
      };
    };
  };
}
