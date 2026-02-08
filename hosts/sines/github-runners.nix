{ config, pkgs, ... }:

{
  age.secrets.gh-actions-runner-dvcorreia-nix-config = {
    file = ../../secrets/gh-actions-runner-dvcorreia-nix-config.age;
  };

  services.github-runners.dvcorreia-nix-config = {
    enable = true;
    name = "sines";
    url = "https://github.com/dvcorreia/nix-config";

    # let systemd allocate a dynamic user & group
    user = null;
    group = null;

    tokenFile = config.age.secrets.gh-actions-runner-dvcorreia-nix-config.path;

    extraLabels = [
      "nixos"
      pkgs.stdenv.hostPlatform.system
    ];
  };
}
