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

  # Plaintext password for the send-only noreply account. Pocket ID also reads
  # this secret for SMTP auth, so it is owned by the pocket-id user (the
  # mailserver reads it at build/activation time as root).
  age.secrets.mailserver-noreply-password = {
    file = ../../secrets/mailserver-noreply-password.age;
    owner = config.services.pocket-id.user;
    group = config.services.pocket-id.group;
    mode = "0640";
  };

  mailserver = {
    enable = true;
    stateVersion = 5;
    fqdn = "mail.dvcorreia.com";
    domains = [ "dvcorreia.com" ];
    systemContact = "postmaster@dvcorreia.com";

    x509.useACMEHost = config.mailserver.fqdn;

    enableSubmission = true;

    fullTextSearch = {
      enable = true;
      autoIndex = true;
      fallback = false;
    };
    indexDir = "/var/lib/dovecot/indices";

    dmarcReporting.enable = true;

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
      "noreply@dvcorreia.com" = {
        passwordFile = config.age.secrets.mailserver-noreply-password.path;
        sendOnly = true;
      };
    };
  };

  services.nginx.virtualHosts.${config.mailserver.fqdn} = {
    enableACME = true;
    forceSSL = true;
  };
}
