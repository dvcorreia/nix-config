{ config, pkgs, ... }:
let
  domain = "headscale.dvcorreia.com";
  tailnetDomain = "dvcorreia.loc";
in
{
  age.secrets.headscale-oidc = {
    file = ../../../secrets/headscale-oidc.age;
    owner = config.services.headscale.user;
    group = "kanidm";
    mode = "0440";
  };

  services.kanidm.provision = {
    groups.headscale_users.members = [
      "dvcorreia"
      "sara"
    ];

    systems.oauth2.headscale = {
      displayName = "Headscale";
      originUrl = "${config.services.headscale.settings.server_url}/oidc/callback";
      originLanding = config.services.headscale.settings.server_url;
      basicSecretFile = config.age.secrets.headscale-oidc.path;
      preferShortUsername = true;
      scopeMaps.headscale_users = [
        "openid"
        "email"
        "profile"
      ];
    };
  };

  systemd.services.headscale = {
    wants = [ "kanidm.service" ];
    after = [ "kanidm.service" ];
  };

  environment.systemPackages = with pkgs; [ headscale ];

  services.headscale = {
    enable = true;
    address = "127.0.0.1"; # default
    port = 8080; # default

    settings = {
      server_url = "https://${domain}";
      dns = {
        magic_dns = true;
        override_local_dns = true;
        base_domain = tailnetDomain;
        search_domains = [ tailnetDomain ];
        nameservers.global = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };
      oidc = {
        issuer = "${config.services.kanidm.server.settings.origin}/oauth2/openid/headscale";
        client_id = "headscale";
        client_secret_path = config.age.secrets.headscale-oidc.path;
        pkce.enabled = true;
      };
      policy.path = ./policies.jsonc;
    };
  };

  users.groups.${config.services.headscale.group}.members = [
    "nginx"
    "dvcorreia"
  ];

  services.nginx.virtualHosts.${domain} = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };
}
