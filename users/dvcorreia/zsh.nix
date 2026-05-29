{ config, inputs, ... }:

let
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
}
