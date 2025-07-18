{
  inputs,
  config,
  lib,
  pkgs,
  isWSL ? false,
  ...
}:

let
  isLinux = pkgs.stdenv.isLinux;

  inherit (lib) mkEnableOption mkIf;

  shellAliases =
    {
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
    }
    // (
      if isLinux && !isWSL then
        {
          pbcopy = "xclip";
          pbpaste = "xclip -o";
        }
      else
        { }
    );

  dotAliases = import (inputs.self + "/lib/dotaliases.nix") { };

  cfg = config._.shells;
in
{
  options._.shells = {
    bash.enable = mkEnableOption "Bash";
    zsh.enable = mkEnableOption "Zsh";
  };

  config.programs.bash = mkIf cfg.bash.enable {
    inherit shellAliases;
    shellOptions = [ ];
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
  };

  config.programs.zsh = mkIf cfg.zsh.enable {
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = shellAliases // dotAliases;

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };
}
