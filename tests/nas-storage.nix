# Asserts the pool derivation: per-disk mounts by label, mergerfs pool
# branches, parity mount, and SnapRAID gating on `parity`.
{ pkgs }:

let
  lib = pkgs.lib;
  pool = import ../hosts/nas/pool.nix;

  withParity = pool {
    inherit lib pkgs;
    disks = [
      "disk1"
      "disk2"
    ];
    parity = "parity";
  };
  withoutParity = pool {
    inherit lib pkgs;
    disks = [ "disk1" ];
  };

  poolFs = withParity.fileSystems."/mnt/storage";

  checks = {
    diskMounts =
      withParity.fileSystems."/mnt/disk1".label == "disk1"
      && withParity.fileSystems."/mnt/disk2".fsType == "ext4";
    poolDevice = poolFs.device == "/mnt/disk1:/mnt/disk2";
    poolDepends =
      poolFs.depends == [
        "/mnt/disk1"
        "/mnt/disk2"
      ];
    parityMount = withParity.fileSystems."/mnt/parity".label == "parity";
    snapraidOn =
      withParity.services.snapraid.enable or false
      && (withParity.services.snapraid.dataDisks.d1 or null) == "/mnt/disk1/"
      && (withParity.services.snapraid.dataDisks.d2 or null) == "/mnt/disk2/"
      && (withParity.services.snapraid.parityFiles or [ ]) == [ "/mnt/parity/snapraid.parity" ];
    snapraidOff = !(withoutParity.services.snapraid ? enable);
  };

  failed = lib.filterAttrs (_: value: !value) checks;
in
if failed == { } then
  pkgs.runCommand "nas-storage-check" { } "touch $out"
else
  throw "nas storage check failed: ${toString (lib.attrNames failed)}"
