pkgs: {
  docs = pkgs.callPackage ./docs.nix { };
  instatic = pkgs.callPackage ./instatic.nix { };
}
