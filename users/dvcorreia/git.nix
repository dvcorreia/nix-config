{ pkgs, ... }:

{
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
      branch.autosetuprebase = "always";
      color.ui = true;
      github.user = "dvcorreia";
      push.default = "upstream";
      push.autoSetupRemote = true;
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
}
