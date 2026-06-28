{ config, ... }:

{
  age.secrets.open-webui-env-file = {
    file = ../../secrets/open-webui-env-file.age;
  };

  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8081;
    openFirewall = false;

    environment = {
      OLLAMA_BASE_URL = "http://proart-7950x.dvcorreia.loc:11434";
      WEBUI_URL = "https://ai.dvcorreia.com";

      OAUTH_CLIENT_ID = "open-webui";
      OPENID_PROVIDER_URL = "https://id.dvcorreia.com/.well-known/openid-configuration";
      OAUTH_PROVIDER_NAME = "Garfo ID";
      OAUTH_SCOPES = "openid email profile";
      OAUTH_CODE_CHALLENGE_METHOD = "S256";
      OPENID_REDIRECT_URI = "https://ai.dvcorreia.com/oauth/oidc/callback";
      ENABLE_OAUTH_SIGNUP = "true";
      ENABLE_LOGIN_FORM = "false";

      ENABLE_PERSISTENT_CONFIG = "false";

      WEBUI_SESSION_COOKIE_SECURE = "true";
      WEBUI_SESSION_COOKIE_SAME_SITE = "lax"; # because of the OAuth redirects
      CORS_ALLOW_ORIGIN = "https://ai.dvcorreia.com";
      FORWARDED_ALLOW_IPS = "127.0.0.1";
    };

    environmentFile = config.age.secrets.open-webui-env-file.path;
  };

  services.nginx.virtualHosts."ai.dvcorreia.com" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.open-webui.port}";
      proxyWebsockets = true;
    };
  };
}
