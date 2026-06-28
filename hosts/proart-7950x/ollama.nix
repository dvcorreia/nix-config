{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cpu;
    host = "0.0.0.0";
    port = 11434;
    openFirewall = false;
    loadModels = [ "qwen3.6:35b" ];

    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "24h"; # CPU inference is slow, don't want model reloading between queries
      OLLAMA_ORIGINS = "https://ai.dvcorreia.com";
    };
  };
}
