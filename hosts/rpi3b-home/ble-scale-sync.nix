{
  config,
  inputs,
  lib,
  ...
}:

let
  # Set to true after replacing every placeholder below and creating the agenix secret.
  enable = false;
in
{
  imports = [
    inputs.self.nixosModules.ble-scale-sync
  ];

  age.secrets = lib.mkIf enable {
    ble-scale-sync-env = {
      file = ../../secrets/ble-scale-sync-env.age;
      owner = "ble-scale-sync";
      group = "ble-scale-sync";
      mode = "0400";
    };
  };

  services.ble-scale-sync = {
    enable = false;

    environmentFile = config.age.secrets.ble-scale-sync-env.path;

    initialSettings = {
      version = 1;

      ble = {
        # Replace with the BF500's MAC address.
        scale_mac = "AA:BB:CC:DD:EE:FF";
        # BF500 displays APP while connected; a short session leaves it usable.
        session_timeout_sec = 20;
      };

      scale = {
        weight_unit = "kg";
        height_unit = "cm";
      };

      # Avoid publishing a measurement when neither user's range matches
      unknown_user = "log";

      users = [
        {
          name = "Diogo";
          slug = "dvcorreia";
          height = 189;
          birth_date = "1996-02-19";
          gender = "male";
          is_athlete = false;
          weight_range = {
            min = 79;
            max = 86;
          };
          beurer_user_index = 1;
          beurer_pin = 0;
        }
        {
          name = "Sara";
          slug = "sarasantosclara";
          height = 180;
          birth_date = "1995-07-23";
          gender = "female";
          is_athlete = false;
          weight_range = {
            min = ;
            max = ;
          };
          beurer_user_index = 2;
          beurer_pin = 0;
        }
      ];

      global_exporters = [
        {
          type = "mqtt";
          # Replace with the broker reachable from rpi3b-home.
          broker_url = "mqtt://mqtt.example.invalid:1883";
          topic = "scale/body-composition";
          password = "\${MQTT_PASSWORD}";
          ha_discovery = true;
          ha_device_name = "Beurer BF500";
        }
      ];

      runtime = {
        continuous_mode = true;
        scan_cooldown = 30;
      };
    };
  };
}
