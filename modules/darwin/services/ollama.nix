{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;
  cfg = config.services.ollama;
in
{
  options = {
    services.ollama = {
      enable = lib.mkEnableOption "Ollama Daemon";
      package = lib.mkPackageOption pkgs "ollama" { };

      host = lib.mkOption {
        type = types.str;
        default = "127.0.0.1";
        example = "0.0.0.0";
        description = ''
          The host address which the ollama server HTTP interface listens to.
        '';
      };

      port = lib.mkOption {
        type = types.port;
        default = 11434;
        example = 11111;
        description = ''
          Which port the ollama server listens to.
        '';
      };

      models = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/path/to/ollama/models";
        description = ''
          The directory that the ollama service will read models from and download new models to.
        '';
      };

      environment = lib.mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          OLLAMA_LLM_LIBRARY = "cpu";
          HIP_VISIBLE_DEVICES = "0,1";
        };
        description = ''
          Set arbitrary environment variables for the ollama service.

          Be aware that these are only seen by the ollama server (launchd daemon),
          not normal invocations like `ollama run`.
          Since `ollama run` is mostly a shell around the ollama server, this is usually sufficient.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    launchd.user.agents.ollama = lib.mkIf pkgs.stdenv.isDarwin {
      path = [ config.environment.systemPath ];

      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        ProgramArguments = [
          "${lib.getExe cfg.package}"
          "serve"
        ];

        EnvironmentVariables =
          cfg.environment
          // {
            OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
          }
          // (lib.optionalAttrs (cfg.models != null) {
            OLLAMA_MODELS = cfg.models;
          });
      };
    };
  };
}
