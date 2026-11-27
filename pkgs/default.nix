pkgs: {
  age-fido2-batch = pkgs.callPackage ./age-fido2-batch { };
  docs = pkgs.callPackage ./docs.nix { };
}
