{ config, ... }:
{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9000;
  };

  services.prometheus.scrapeConfigs = [
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
