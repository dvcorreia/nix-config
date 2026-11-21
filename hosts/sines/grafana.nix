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
    group = "kanidm";
    mode = "0440";
  };

  services.kanidm.provision = {
    groups = {
      grafana_users.members = [ "grafana_editors" ];
      grafana_editors.members = [ "dvcorreia" ];
    };

    systems.oauth2.grafana = {
      displayName = "Grafana";
      originUrl = "${config.services.grafana.settings.server.root_url}login/generic_oauth";
      originLanding = config.services.grafana.settings.server.root_url;
      basicSecretFile = config.age.secrets.grafana-oauth2-client-secret.path;
      preferShortUsername = true;
      scopeMaps.grafana_users = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
      claimMaps.grafana_role = {
        joinType = "array";
        valuesByGroup.grafana_editors = [ "Editor" ];
      };
    };
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
        auth_url = "${config.services.kanidm.server.settings.origin}/ui/oauth2";
        token_url = "${config.services.kanidm.server.settings.origin}/oauth2/token";
        api_url = "${config.services.kanidm.server.settings.origin}/oauth2/openid/grafana/userinfo";
        use_pkce = true;
        login_attribute_path = "preferred_username";
        email_attribute_path = "email";
        allow_assign_grafana_admin = false; # default
        role_attribute_path = "contains(grafana_role[*], 'Editor') && 'Editor' || 'Viewer'";
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
