{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ble-scale-sync;
  yaml = pkgs.formats.yaml { };
in
{
  options.services.ble-scale-sync = {
    enable = lib.mkEnableOption "BLE Scale Sync";

    package = lib.mkPackageOption pkgs "ble-scale-sync" { };

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ble-scale-sync/config.yaml";
      description = "Path to the writable, service-owned BLE Scale Sync YAML configuration.";
    };

    initialSettings = lib.mkOption {
      type = lib.types.nullOr yaml.type;
      default = null;
      example = lib.literalExpression ''
        {
          version = 1;
          ble = {
            scale_mac = "AA:BB:CC:DD:EE:FF";
            session_timeout_sec = 20;
          };
          users = [
            {
              name = "Alice";
              slug = "alice";
              height = 168;
              birth_date = "1995-03-20";
              gender = "female";
              is_athlete = false;
              weight_range = { min = 50; max = 75; };
              beurer_user_index = 1;
              beurer_pin = 1234;
            }
          ];
          global_exporters = [
            {
              type = "mqtt";
              broker_url = "mqtt://broker.example:1883";
              password = "''${MQTT_PASSWORD}";
            }
          ];
          runtime.continuous_mode = true;
        }
      '';
      description = ''
        Initial BLE Scale Sync configuration. It is copied to {option}`configFile`
        only if that file does not already exist, allowing BLE Scale Sync to persist
        `last_known_weight` without Nix overwriting it on subsequent activations.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/agenix/ble-scale-sync.env";
      description = ''
        Dotenv-format file loaded by systemd. Use an agenix secret here for values
        referenced in {option}`initialSettings` such as `''${MQTT_PASSWORD}`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    users.groups.ble-scale-sync = { };
    users.users.ble-scale-sync = {
      isSystemUser = true;
      group = "ble-scale-sync";
      extraGroups = [ "bluetooth" ];
    };

    systemd.services.ble-scale-sync = {
      description = "BLE Scale Sync";
      documentation = [ "https://github.com/KristianP26/ble-scale-sync" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "bluetooth.service" ];
      wants = [ "bluetooth.service" ];

      unitConfig.StartLimitIntervalSec = 0;
      unitConfig.ConditionPathExists = lib.mkIf (cfg.initialSettings == null) cfg.configFile;

      preStart = lib.mkIf (cfg.initialSettings != null) ''
        if [ ! -e ${lib.escapeShellArg cfg.configFile} ]; then
          ${pkgs.coreutils}/bin/install -D -m 0600 \
            ${yaml.generate "ble-scale-sync-config.yaml" cfg.initialSettings} \
            ${lib.escapeShellArg cfg.configFile}
        fi
      '';

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} --config ${cfg.configFile}";
        Type = "notify";
        WatchdogSec = "60s";
        NotifyAccess = "main";
        Restart = "on-failure";
        RestartSec = "10s";
        User = "ble-scale-sync";
        Group = "ble-scale-sync";
        StateDirectory = "ble-scale-sync";
        StateDirectoryMode = "0750";
        WorkingDirectory = "/var/lib/ble-scale-sync";
        Environment = "HOME=/var/lib/ble-scale-sync";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/ble-scale-sync" ];
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
      };
    };
  };
}
