{ config, pkgs, ... }:
let
  domain = "rss.dvcorreia.com";
  issuer = config.services.pocket-id.settings.APP_URL;
in
{
  age.secrets.miniflux-oauth2-client-secret.file = ../../secrets/miniflux-oauth2-client-secret.age;

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "127.0.0.1:8081";
      BASE_URL = "https://${domain}";
      HTTPS = 1;

      CREATE_ADMIN = false;
      DISABLE_LOCAL_AUTH = 1;

      OAUTH2_PROVIDER = "oidc";
      OAUTH2_OIDC_PROVIDER_NAME = config.services.pocket-id.settings.APP_NAME;
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = issuer;
      OAUTH2_CLIENT_ID = "miniflux";
      OAUTH2_CLIENT_SECRET_FILE = "/run/credentials/miniflux.service/oauth2-client-secret";
      OAUTH2_REDIRECT_URL = "https://${domain}/oauth2/oidc/callback";
      OAUTH2_USER_CREATION = 1;
      OAUTH2_ADDITIONAL_SCOPES = "groups";
      OAUTH2_GROUP_CLAIM = "groups";
      OAUTH2_ADMIN_GROUP = "admin";
    };
  };

  systemd.services.miniflux = {
    serviceConfig.LoadCredential = "oauth2-client-secret:${config.age.secrets.miniflux-oauth2-client-secret.path}";

    # Miniflux only runs OIDC discovery once at startup and never retries, so
    # wait for the issuer or the login page comes up without a sign-in button.
    preStart = ''
      ${pkgs.curl}/bin/curl --fail --silent --output /dev/null \
        --retry 30 --retry-delay 2 --retry-max-time 60 --retry-all-errors \
        ${issuer}/.well-known/openid-configuration
    '';
  };

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.miniflux.config.LISTEN_ADDR}";
  };
}
