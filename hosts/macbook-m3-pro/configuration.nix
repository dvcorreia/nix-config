{
  inputs,
  currentSystem,
  ...
}:

{
  imports = with inputs.self.darwinModules; [
    ../darwin-shared.nix
  ];

  nix = {
    settings = {
      experimental-features = [
        "cgroups"
        "dynamic-derivations"
        "flakes"
        "nix-command"
        "recursive-nix"
      ];
      auto-optimise-store = false; # not true because of https://github.com/NixOS/nix/issues/7273
      sandbox = true;
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      interval = {
        Hour = 21;
        Minute = 0;
      };
    };
  };

  nixpkgs.hostPlatform.system = currentSystem;
}
