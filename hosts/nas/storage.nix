# Data pool following the Perfect Media Server model: one filesystem per disk,
# pooled with mergerfs at /mnt/storage, with SnapRAID parity once a parity disk
# exists. The derivation lives in pool.nix; this module owns the disk
# inventory — the only thing you edit.
#
# Data disks are mounted by label and never declared in any imported disko
# config, so reinstalling NixOS can never wipe them.
{ lib, pkgs, ... }:

let
  # Add a data disk: `nix run .#disk -- <host> <device-by-id> <label>`, then
  # append its label here.
  disks = [ "disk1" ];

  # Set to "parity" once a disk at least as large as the biggest data disk is
  # formatted with that label.
  parity = null;

  pool = import ./pool.nix {
    inherit
      lib
      pkgs
      disks
      parity
      ;
  };
in
{
  imports = [ pool ];
}
