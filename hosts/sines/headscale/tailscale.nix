{ ... }:
{
  # it is fine to manually authenticate here
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
