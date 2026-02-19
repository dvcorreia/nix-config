{ config, ... }:
{
  age.secrets.ups-passwd = {
    file = ../../secrets/ups-passwd.age;
  };

  power.ups = {
    enable = true;
    mode = "standalone";

    upsd = {
      listen = [
        {
          address = "127.0.0.1";
          port = 3493;
        }
      ];
    };

    # virtual user (not related to /etc/passwd users) with write access to UPS
    users."nut-admin" = {
      passwordFile = config.age.secrets.ups-passwd.path;
      upsmon = "primary";
    };

    ups."eaton-ellipse-pro" = {
      description = "Eaton Ellipse PRO Line-Interactive 1200VA/750W (IEC) USB lead-acid Batt";
      driver = "usbhid-ups";
      port = "auto";

      directives = [
        # "Restore power on AC" BIOS option needs power to be cut a few seconds to work.
        # This is achieved by the offdelay and ondelay directives.
        # In the last stages of system shutdown, "upsdrvctl shutdown" is called to tell UPS that
        # after offdelay seconds, the UPS power must be cut, even if wall power returns.

        # There is a danger that the system will take longer than the default 20 seconds to shut down.
        # If that were to happen, the UPS shutdown would provoke a brutal system crash.
        # We adjust offdelay, to solve this issue.
        "offdelay = 60"

        # UPS power is now cut regardless of wall power.
        # After (ondelay minus offdelay) seconds, if wall power returns, turn on UPS power.
        # The system has now been disconnected for a minimum of (ondelay minus offdelay) seconds,
        # "Restore power on AC" should now power on the system.
        # For reasons described above, ondelay value must be larger than offdelay value.
        # We adjust ondelay, to ensure Restore power on AC option returns to Power Disconnected state.
        "ondelay = 70"

        # set value for battery.charge.low,
        # upsmon initiate shutdown once this threshold is reached.
        "lowbatt = 10"

        # ignore it if the UPS reports a low battery condition
        # without this, system will shutdown only when ups reports lb,
        # not respecting lowbatt option
        "ignorelb"
      ];
    };

    upsmon.monitor."eaton-ellipse-pro" = {
      user = "nut-admin";
      passwordFile = config.age.secrets.ups-passwd.path;
      type = "primary";
    };

    upsmon.settings = {
      NOTIFYFLAG = [
        [
          "ONLINE"
          "SYSLOG+WALL"
        ]
        [
          "ONBATT"
          "SYSLOG+WALL"
        ]
        [
          "LOWBATT"
          "SYSLOG+WALL"
        ]
        [
          "SHUTDOWN"
          "SYSLOG+WALL"
        ]
        [
          "COMMBAD"
          "SYSLOG+WALL"
        ]
      ];
      NOCOMMWARNTIME = 300;
      FINALDELAY = 0;
    };
  };
}
