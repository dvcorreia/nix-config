{
  config,
  pkgs,
  lib,
  ...
}:

# sometimes I need a linux machine to work
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "vagrant"
      "Oracle_VirtualBox_Extension_Pack"
    ];

  environment.systemPackages = with pkgs; [
    git
    vagrant
    uv
  ];

  # allow uv to run dynamically linked Python interpreters
  programs.nix-ld.enable = true;

  services.vscode-server.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "dvcorreia" ];

  # load VirtualBox kernel modules at boot
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.virtualbox ];
    kernelModules = [
      "vboxdrv"
      "vboxnetflt"
      "vboxnetadp"
    ];
  };

  # see: https://nixos.wiki/wiki/Vagrant
  services.nfs.server.enable = true;
  networking.firewall.extraCommands = ''
    ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT
  '';

  # see: https://www.virtualbox.org/ticket/22248
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
}
