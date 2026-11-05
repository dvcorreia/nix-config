# Pure builder for the NAS data pool, called by storage.nix (which owns the
# disk inventory). Derives per-disk mounts, the mergerfs pool at /mnt/storage,
# and SnapRAID parity.
{
  lib,
  pkgs,
  disks,
  parity ? null,
}:

let
  diskMounts = map (label: "/mnt/${label}") disks;

  ext4Mount = label: {
    inherit label;
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };
in
{
  # Makes mount.mergerfs available to systemd (same mechanism as the bindfs and
  # unionfs-fuse modules in nixpkgs).
  system.fsPackages = [ pkgs.mergerfs ];

  fileSystems =
    (lib.listToAttrs (map (label: lib.nameValuePair "/mnt/${label}" (ext4Mount label)) disks))
    // (lib.optionalAttrs (parity != null) {
      "/mnt/${parity}" = ext4Mount parity;
    })
    // {
      # PMS-style pool: every disk becomes another /mnt/<label> branch.
      "/mnt/storage" = {
        device = lib.concatStringsSep ":" diskMounts;
        fsType = "mergerfs";
        noCheck = true;
        depends = diskMounts;
        options = [
          "cache.files=off"
          "category.create=pfrd"
          "func.getattr=newest"
          "dropcacheonclose=false"
          "minfreespace=200G"
          "branches-mount-timeout=30"
          "branches-mount-timeout-fail=true"
          "x-systemd.mount-timeout=45s"
          "fsname=mergerfs"
        ];
      };
    };

  # Parity needs a disk at least as large as the biggest data disk.
  services.snapraid = lib.optionalAttrs (parity != null) {
    enable = true;
    dataDisks = lib.listToAttrs (
      lib.imap0 (i: label: lib.nameValuePair "d${toString (i + 1)}" "/mnt/${label}/") disks
    );
    parityFiles = [ "/mnt/${parity}/snapraid.parity" ];
    contentFiles = [ "/var/snapraid.content" ] ++ map (mount: "${mount}/snapraid.content") diskMounts;
    exclude = [
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
    ];
  };
}
