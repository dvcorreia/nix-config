{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;

    enableMcpIntegration = true;
  };
}
