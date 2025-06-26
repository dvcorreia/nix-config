_: {
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    extraOptions = ''
      auto-optimise-store = false # not true because of https://github.com/NixOS/nix/issues/7273
      extra-platforms = x86_64-darwin
      sandbox = true
    '';

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };
}
