{
  pkgs,
  system,
  inputs,
}:

let
  sshKeys = import ./../secrets/ssh-keys.nix { };
  installationScript = inputs.agenix-shell.lib.installationScript system {
    secrets = {
      TF_VAR_hcloud_token.file = ./../secrets/hetzner-homelab-api-token.age;
      TF_VAR_cloudflare_api_token.file = ./../secrets/cloudflare-dns-token.age;
      TF_VAR_passphrase.file = ./../secrets/opentofu-encryption-key.age;
    };
  };
in

pkgs.mkShell {
  packages = with pkgs; [
    git
    gnumake
    openssh
    opentofu
    inputs.agenix.packages.${system}.default
  ];

  shellHook = ''
    source ${pkgs.lib.getExe installationScript}
  '';

  TF_VAR_ssh_pub_key = sshKeys.yubikey1-ed25519-sk;
  TF_VAR_cloudflare_zone_id = "6f9c7fc4fe11ede15a136982bedcad85";
  TF_VAR_cloudflare_account_id = "35db5f9742873a380407761666ef726b";
}
