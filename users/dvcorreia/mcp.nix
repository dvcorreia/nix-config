{
  inputs,
  pkgs,
  lib,
  currentSystem,
  ...
}:

let
  inherit (inputs.mcp-nixos.packages.${currentSystem}) mcp-nixos;
in
{
  programs.mcp = {
    enable = true;
    servers = {
      mcp-nixos.command = lib.getExe mcp-nixos;
      terraform-mcp-server.command = lib.getExe pkgs.terraform-mcp-server;
    };
  };
}
