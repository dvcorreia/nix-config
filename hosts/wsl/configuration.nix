{
  currentSystemUser,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../nixos-shared.nix
  ];

  networking.hostName = "wsl";

  wsl = {
    enable = true;
    defaultUser = currentSystemUser;
  };

  # solution adapted from: https://github.com/K900/vscode-remote-workaround
  # more information: https://github.com/nix-community/NixOS-WSL/issues/238 and https://github.com/nix-community/NixOS-WSL/issues/294
  systemd.user = {
    paths.vscode-remote-workaround = {
      wantedBy = [ "default.target" ];
      pathConfig.PathChanged = "%h/.vscode-server/bin";
    };
    services.vscode-remote-workaround.script = ''
      for i in ~/.vscode-server/bin/*; do
        if [ -e $i/node ]; then
          echo "Fixing vscode-server in $i..."
          ln -sf ${pkgs.nodejs_23}/bin/node $i/node
        fi
      done
    '';
  };
}
