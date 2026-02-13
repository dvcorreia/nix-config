{ config, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9001;
    listenAddress = "0.0.0.0";
    enabledCollectors = [
      "systemd"
      "processes"
    ];
  };
}
