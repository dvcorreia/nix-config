{
  config,
  inputs,
  pkgs,
  ...
}:

let
  currentSystem = "aarch64-darwin";
  inherit (inputs.self) sshKeys;
in
{
  imports = [
    ../../modules/nix.nix
    inputs.self.darwinModules.system-defaults
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.home-manager.darwinModules.home-manager
  ];

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/LnL7/nix-darwin/issues/423).
  users.users.dvcorreia = {
    home = "/Users/dvcorreia";
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      sshKeys.dvcorreia
      sshKeys.yubikey1-ed25519-sk
    ];
  };

  system.primaryUser = "dvcorreia";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs currentSystem; };
    users.dvcorreia = import ../../users/dvcorreia;
  };

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  # add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  nixpkgs = {
    overlays = [
      inputs.self.overlays.unstable-packages
      inputs.self.overlays.patches
    ];
    config = {
      allowUnfreePredicate =
        pkg:
        builtins.elem (pkg.pname) [
          "vscode"
          "vscode-extension-MS-python-vscode-pylance"
        ];
    };
    hostPlatform.system = currentSystem;
  };

  system.defaults.dock.persistent-apps = [
    "/Applications/Safari.app"
    "/Applications/Google Chrome.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Calendar.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Notes.app"
    "/Applications/NetNewsWire.app"
    "/Applications/Spotify.app"
    "/Applications/Telegram.app"
    "/Applications/Discord.app"
  ];

  nix-homebrew =
    let
      isAarch64 = builtins.match "aarch64-.*" currentSystem != null;
    in
    {
      enable = true;
      enableRosetta = isAarch64;
      mutableTaps = true;
      user = "dvcorreia";
      taps = with inputs; {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
      };
    };

  homebrew = {
    enable = true;
    enableZshIntegration = config.programs.zsh.enable;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      "homebrew/core"
      "homebrew/cask"
    ];
    brews = [
      "cookcli"
    ];
    casks = [
      "ghostty"
      "tailscale"
      "google-chrome"
      "brave-browser"
      "telegram"
      "transmission"
      "vlc"
      "stremio"
      "discord"
      "rectangle"
      "spotify"
      "stats"
      "netnewswire"
      "pika"
      "reminders-menubar"
      "freecad"
      "kicad"
      "docker-desktop"
      "signal"
      "jordanbaird-ice" # menu bar management tool
    ];
  };

  environment.systemPackages = with pkgs; [
    gnumake
    openssh
    tailscale
    unstable.opencode
    gh
  ];

  nix = {
    distributedBuilds = true;

    linux-builder = {
      enable = true;
      ephemeral = true;
      supportedFeatures = [
        "kvm"
        "nixos-test"
      ];

      config.virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 4 * 1024;
        };
        cores = 4;
      };
    };

    buildMachines =
      let
        inherit (inputs.self.nixosConfigurations) proart-7950x sines;
        proart-7950x-hostname = proart-7950x.config.networking.hostName;
        tailscaleDomain = sines.config.services.headscale.settings.dns.base_domain;
      in
      [
        {
          hostName = "${proart-7950x-hostname}.${tailscaleDomain}";
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          sshUser = "dvcorreia";
          sshKey = "/Users/dvcorreia/.ssh/id_ed25519";
          protocol = "ssh-ng";
          maxJobs = 16;
          speedFactor = 2;
          supportedFeatures = [
            "kvm"
            "nixos-test"
            "big-parallel"
          ];
        }
      ];
  };

  services.openssh.enable = true;

  fonts.packages = with pkgs; [
    monaspace
    jetbrains-mono
    mononoki
    fira
  ];

  system.stateVersion = 5;
}
