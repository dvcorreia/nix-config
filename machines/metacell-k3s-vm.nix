{
  config,
  pkgs,
  lib,
  microvm
  ...
}:

{
  imports = [ microvm.host ];

  # MicroVM settings
  microvm = {

  };

  microvm.nixosModules.microvm {
    networking.hostName = "metacell-k3s-vm";
    networking.useNetworkd = true;

    users.users.root.password = "";

    microvm = {
      mem = 8192; # RAM allocation in MB
      vcpu = 4; # Number of Virtual CPU cores

      interfaces = [
        {
          type = "user";
          id = "vm-metacell-k3s"; # should be prefixed with "vm-"
          mac = "02:00:00:01:01:01"; # Unique MAC address
        }
      ];

      # Block device images for persistent storage
      # microvm use tmpfs for root(/), so everything else
      # is ephemeral and will be lost on reboot.
      #
      # you can check this by running `df -Th` & `lsblk` in the VM.
      volumes = [
        {
          mountPoint = "/var";
          image = "var.img";
          size = 204800; # volume allocation in MB
        }
      ];

      # shares can not be set to `neededForBoot = true;`
      # so if you try to use a share in boot script(such as system.activationScripts), it will fail!
      shares = [
        {
          # It is highly recommended to share the host's nix-store
          # with the VMs to prevent building huge images.
          # a host's /nix/store will be picked up so that no
          # squashfs/erofs will be built for it.
          #
          # by this way, /nix/store is readonly in the VM,
          # and thus the VM can't run any command that modifies
          # the store. such as nix build, nix shell, etc...
          # if you want to run nix commands in the VM, see
          # https://github.com/astro/microvm.nix/blob/main/doc/src/shares.md#writable-nixstore-overlay
          tag = "ro-store"; # Unique virtiofs daemon tag
          proto = "virtiofs"; # virtiofs is faster than 9p
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
      ];

      hypervisor = "qemu";
      # Control socket for the Hypervisor so that a MicroVM can be shutdown cleanly
      socket = "control.socket";
    };

    system.stateVersion = "24.05";
  }

  microvm.vms = {
    metacell-k3s-vm = {
      # Host build-time reference to where the MicroVM NixOS is defined
      # under nixosConfigurations
      flake = self;
      # Specify from where to let `microvm -u` update later on
      updateFlake = "git+file:///etc/nixos";
    };
  }

  microvm.autostart = [
    "metacell-k3s-vm"
  ];

  # ---------

  systemd.network.networks."10-lan" = {
    matchConfig.Name = ["eno1" "vm-*"];
    networkConfig = {
      Bridge = "br0";
    };
  };

  systemd.network.netdevs."br0" = {
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "br0";
    networkConfig = {
      Address = ["192.168.1.2/24" "2001:db8::a/64"];
      Gateway = "192.168.1.1";
      DNS = ["192.168.1.1"];
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };
}
