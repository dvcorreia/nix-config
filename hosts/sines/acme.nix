{ config, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "dv_correia@hotmail.com";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nginx = {
    enable = true;

    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
  };

  # set the group to acme and that anyone in the group can read the keys
  users.groups.acme = {
    members = [
      config.services.nginx.user
    ];
  };
}
