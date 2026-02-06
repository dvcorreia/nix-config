{ config, ... }:
{
  age.secrets.grafana-secret-key = {
    file = ../../secrets/grafana-secret-key.age;
    owner = "grafana"; # does not expose config.services.grafana.user
    group = "grafana"; # does not expose config.services.grafana.group
  };

  age.secrets.grafana-oauth2-client-secret = {
    file = ../../secrets/grafana-oauth2-client-secret.age;
    owner = "grafana";
    group = "grafana";
  };

  services.grafana = {
    enable = true;
    settings = {
      analytics.reporting_enabled = false;

      server = {
        http_addr = "127.0.0.1";
        http_port = 2342;
        enforce_domain = true;
        enable_gzip = true;
        domain = "monitor.dvcorreia.com";
        root_url = "https://monitor.dvcorreia.com/";
      };

      security = {
        disable_initial_admin_creation = true;
        secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
        cookie_secure = true;
        disable_gravatar = true;
        hide_version = true;
      };

      auth.disable_login_form = true;
      "auth.generic_oauth" = {
        enabled = true;
        name = "Garfo ID";
        icon = "signin"; # default
        allow_sign_up = true; # automatically  creates new user if a user successfully authenticates and doesn't already exists
        auto_login = false; # automatically redirects users to the OAuth provider instead of showing the Grafana login page
        client_id = "grafana";
        client_secret = "$__file{${config.age.secrets.grafana-oauth2-client-secret.path}}";
        scopes = "openid email profile groups";
        auth_url = "${config.services.pocket-id.settings.APP_URL}/authorize";
        token_url = "${config.services.pocket-id.settings.APP_URL}/api/oidc/token";
        api_url = "${config.services.pocket-id.settings.APP_URL}/api/oidc/userinfo";
        use_pkce = true;
        email_attribute_name = "email:primary"; # default
        allow_assign_grafana_admin = false; # default
        role_attribute_path = "contains(groups[*], 'admin') && 'Editor' || 'Viewer'";
      };
    };

    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          name = "Sines Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          isDefault = true;
          editable = false;
        }
      ];
    };
  };

  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };
}
