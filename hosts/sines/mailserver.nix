{ config, ... }:
{
  age.secrets.mailserver-dvcorreia-password = {
    file = ../../secrets/mailserver-dvcorreia-password.age;
    owner = "vmail";
    group = "vmail";
  };

  mailserver = {
    enable = true;
    stateVersion = 5;
    fqdn = "mail.dvcorreia.com";
    domains = [ "dvcorreia.com" ];

    x509.useACMEHost = config.mailserver.fqdn;

    srs = {
      enable = true;
      domain = "srs.dvcorreia.com";
    };

    accounts = {
      "dvcorreia@dvcorreia.com" = {
        hashedPasswordFile = config.age.secrets.mailserver-dvcorreia-password.path;
        aliases = [ "postmaster@dvcorreia.com" ];
      };
    };
  };

  services.nginx.virtualHosts.${config.mailserver.fqdn} = {
    enableACME = true;
    forceSSL = true;
  };

  networking.firewall.allowedTCPPorts = [
    25
    465
    587
    993
    995
  ];
}
