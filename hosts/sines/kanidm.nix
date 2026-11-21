{ config, pkgs, ... }:
let
  domain = "id.dvcorreia.com";
  cert = config.security.acme.certs.${domain};
in
{
  services.kanidm = {
    package = pkgs.kanidm_1_12.withSecretProvisioning;

    server = {
      enable = true;
      settings = {
        version = "2";
        inherit domain;
        origin = "https://${domain}";
        bindaddress = "127.0.0.1:8443";
        tls_chain = "${cert.directory}/fullchain.pem";
        tls_key = "${cert.directory}/key.pem";
        http_client_address_info.x-forward-for = [ "127.0.0.1" ];
        online_backup.versions = 7;
      };
    };

    client = {
      enable = true;
      settings.uri = config.services.kanidm.server.settings.origin;
    };

    provision = {
      enable = true;
      autoRemove = true;
      persons = {
        dvcorreia = {
          displayName = "dvcorreia";
          mailAddresses = [ "dv_correia@hotmail.com" ];
        };
        sara = {
          displayName = "Sara";
          mailAddresses = [ "sarasantosclara@gmail.com" ];
        };
      };
    };
  };

  security.acme.certs.${domain} = {
    group = "kanidm-tls";
    reloadServices = [ "kanidm.service" ];
  };

  users.groups.kanidm-tls.members = [
    "kanidm"
    config.services.nginx.user
  ];

  systemd.services.kanidm = {
    requires = [ "acme-${domain}.service" ];
    after = [ "acme-${domain}.service" ];
  };

  services.nginx.virtualHosts.${domain} = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "https://${config.services.kanidm.server.settings.bindaddress}";
      extraConfig = ''
        proxy_ssl_verify on;
        proxy_ssl_server_name on;
        proxy_ssl_name ${domain};
        proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
        proxy_ssl_verify_depth 2;
      '';
    };
  };
}
