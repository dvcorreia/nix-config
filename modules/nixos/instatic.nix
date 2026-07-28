{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types optionalAttrs concatStringsSep;
  cfg = config.services.instatic;
  stateDir = "/var/lib/instatic";
in
{
  options.services.instatic = {
    enable = mkEnableOption "Instatic CMS";

    package = mkOption {
      type = types.package;
      default = pkgs.instatic;
      defaultText = lib.literalExpression "pkgs.instatic";
      description = "Instatic package to use.";
    };

    port = mkOption {
      type = types.port;
      default = 3001;
      description = "Port the service listens on.";
    };

    databaseUrl = mkOption {
      type = types.str;
      default = "sqlite:${stateDir}/data/cms.db";
      defaultText = lib.literalExpression ''"sqlite:''${stateDir}/data/cms.db"'';
      description = "Database connection URL.";
    };

    uploadsDir = mkOption {
      type = types.path;
      default = "${stateDir}/uploads";
      defaultText = lib.literalExpression "''${stateDir}/uploads";
      description = "Directory for uploaded media and published artefacts.";
    };

    secretKeyFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/run/secrets/instatic-env";
      description = ''
        Path to a file containing `INSTATIC_SECRET_KEY=...`. Loaded via
        systemd EnvironmentFile. Required before adding AI provider credentials,
        saving plugin secret settings, or enabling TOTP MFA.
      '';
    };

    publicOrigin = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Public origin URL (e.g. https://cms.example.com) for CSRF checks.";
    };

    trustedProxyCidrs = mkOption {
      type = types.listOf types.str;
      default = [ "127.0.0.1/32" "::1/128" ];
      description = "CIDR ranges of trusted reverse proxies.";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Extra environment variables passed to the service.";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${stateDir} 0750 instatic instatic -"
      "d ${cfg.uploadsDir} 0750 instatic instatic -"
    ];

    systemd.services.instatic = {
      description = "Instatic CMS";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "instatic";
        Group = "instatic";
        WorkingDirectory = "${cfg.package}/lib/instatic";
        ExecStart = "${cfg.package}/bin/instatic";
        Restart = "on-failure";
        RestartSec = "5s";
        StateDirectory = "instatic";
        StateDirectoryMode = "750";
        ReadWritePaths = [ stateDir cfg.uploadsDir ];
        NoNewPrivileges = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        PrivateTmp = true;
      }
      // optionalAttrs (cfg.secretKeyFile != null) { EnvironmentFile = cfg.secretKeyFile; };

      environment =
        {
          PORT = toString cfg.port;
          DATABASE_URL = cfg.databaseUrl;
          UPLOADS_DIR = cfg.uploadsDir;
          STATIC_DIR = "${cfg.package}/lib/instatic/dist";
          TRUSTED_PROXY_CIDRS = concatStringsSep "," cfg.trustedProxyCidrs;
        }
        // optionalAttrs (cfg.publicOrigin != null) { PUBLIC_ORIGIN = cfg.publicOrigin; }
        // cfg.environment;
    };

    users.users.instatic = {
      isSystemUser = true;
      group = "instatic";
      description = "Instatic CMS service user";
    };

    users.groups.instatic = { };
  };
}
