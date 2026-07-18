{ inputs, config, ... }:
{
  imports = [
    inputs.nixos-mailserver.nixosModules.default
  ];

  age.secrets.mailserver-dvcorreia-password = {
    file = ../../secrets/mailserver-dvcorreia-password.age;
    owner = config.mailserver.storage.owner;
    group = config.mailserver.storage.group;
  };

  mailserver = {
    enable = true;
    stateVersion = 5;
    fqdn = "mail.dvcorreia.com";
    domains = [ "dvcorreia.com" ];
    systemContact = "postmaster@dvcorreia.com";

    x509.useACMEHost = config.mailserver.fqdn;

    enableSubmission = true;

    srs = {
      enable = true;
      domain = "srs.dvcorreia.com";
    };

    accounts = {
      "diogo@dvcorreia.com" = {
        hashedPasswordFile = config.age.secrets.mailserver-dvcorreia-password.path;
        aliases = [
          "postmaster@dvcorreia.com"
          "me@dvcorreia.com"
        ];
      };
    };
  };

  services.nginx.virtualHosts.${config.mailserver.fqdn} = {
    enableACME = true;
    forceSSL = true;
  };
}
