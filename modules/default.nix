# TODO: empty here for module docs generation to work
{
  nixosModules = { };
  darwinModules = {
    system-defaults = import ./darwin/system-defaults.nix;
  };
  homeManagerModules = { };
}
