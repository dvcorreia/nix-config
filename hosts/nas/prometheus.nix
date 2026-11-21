{ ... }:
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

  # Disk temperatures and SMART health. drivetemp/hwmon is not used because this
  # drive's SCT log lags behind the live SMART temperature.
  # by-id keeps labels stable across /dev/sdX renames.
  services.prometheus.exporters.smartctl = {
    enable = true;
    listenAddress = "0.0.0.0";
    extraFlags = [ "--smartctl.scan-device-type=by-id" ];
  };
}
