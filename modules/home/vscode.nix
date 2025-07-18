{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.vscode;
in

{
  options.programs.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
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
  };
}
