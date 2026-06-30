{ config, inputs, ... }:

let
  ollama = config.services.ollama;
in
{
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  age.secrets.hermes-env = {
    file = ../../secrets/hermes-env.age;
    owner = config.services.hermes-agent.user;
    group = config.services.hermes-agent.group;
  };

  services.hermes-agent = {
    enable = true;

    settings.model = {
      provider = "custom";
      default = builtins.head ollama.loadModels;
      base_url = "http://127.0.0.1:${toString ollama.port}/v1";
    };

    environment = {
      HERMES_API_TIMEOUT = "1800"; # 30 minutes for slow CPU inference
      TELEGRAM_ALLOWED_USERS = "541167278";
    };

    environmentFiles = [ config.age.secrets.hermes-env.path ];
    addToSystemPackages = true;

    extraDependencyGroups = [ "messaging" ];
  };
}
