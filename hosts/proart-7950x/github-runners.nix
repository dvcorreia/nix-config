{ config, pkgs, ... }:
{
  age.secrets.gh-actions-runner-dvcorreia-nix-config = {
    file = ../../secrets/gh-actions-runner-dvcorreia-nix-config.age;
  };

  services.github-runners.dvcorreia-nix-config = {
    enable = true;
    name = "proart-7950x";
    url = "https://github.com/dvcorreia/nix-config";

    # let systemd allocate a dynamic user & group
    user = null;
    group = null;

    tokenFile = config.age.secrets.gh-actions-runner-dvcorreia-nix-config.path;

    extraLabels = [
      "nixos"
      pkgs.stdenv.hostPlatform.system
    ];

    serviceOverrides = {
      CPUQuota = "800%"; # 8 cores
      TasksMax = 8192;
      MemoryMax = "48G";
      MemorySwapMax = "64G";
      OOMScoreAdjust = 500; # kill first if the system runs out of memory
    };
  };
}
