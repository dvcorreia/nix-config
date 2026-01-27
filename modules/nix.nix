{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv) isDarwin;
in
{
  nix = lib.mkMerge [
    {
      package = pkgs.nixVersions.latest;

      settings = {
        experimental-features = [
          "cgroups"
          "dynamic-derivations"
          "flakes"
          "nix-command"
          "recursive-nix"
        ];

        trusted-users = [
          "root"
          "@wheel"
          "dvcorreia"
        ];

        substituters = [
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        warn-dirty = false;
      };
    }

    (lib.optionalAttrs (!isDarwin) {
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
        dates = "weekly";
      };
    })

    (lib.optionalAttrs isDarwin {
      settings = {
        # Causes annoying "cannot link ... to ...: File exists" errors on Darwin
        # see: https://github.com/NixOS/nix/issues/7273
        auto-optimise-store = lib.mkForce false;
      };

      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
        interval = {
          Hour = 13;
          Minute = 00;
        };
      };
    })
  ];
}
