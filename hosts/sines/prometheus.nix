{ config, inputs, ... }:

{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9000;
  };

  services.prometheus.scrapeConfigs =
    let
      tsAddress = hostname: "${hostname}.${config.services.headscale.settings.dns.base_domain}";
    in
    [
      {
        job_name = "sines";
        static_configs = [
          {
            targets = [
              "${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
      {
        job_name = "proart-7950x";
        static_configs =
          let
            inherit (inputs.self.nixosConfigurations) proart-7950x;
            inherit (proart-7950x.config.networking) hostName;
            inherit (proart-7950x.config.services.prometheus.exporters.node) port;
          in
          [
            {
              targets = [ "${tsAddress hostName}:${toString port}" ];
            }
          ];
      }
    ];

  services.prometheus.exporters.node = {
    enable = true;
    port = 9001;
    listenAddress = "127.0.0.1";
    enabledCollectors = [
      "systemd"
      "processes"
    ];
  };
}
