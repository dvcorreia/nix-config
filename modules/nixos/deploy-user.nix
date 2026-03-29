{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.deploy = {
    isNormalUser = false;
    isSystemUser = true;
    home = "/var/lib/deploy";
    group = "deploy";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKURVu1hE+aKAK/O8rB1hEbmQ18fPokpit5JeREtrqOQ deploy@proart-7950x"
    ];
  };

  users.groups.deploy = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/deploy 0700 deploy deploy -"
    "d /var/lib/deploy/.ssh 0700 deploy deploy -"
  ];

  security.sudo.extraRules = [
    {
      users = [ "deploy" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
