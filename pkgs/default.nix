pkgs: {
  docs = pkgs.callPackage ./docs.nix { };
  ble-scale-sync = pkgs.callPackage ./ble-scale-sync.nix { };
}
