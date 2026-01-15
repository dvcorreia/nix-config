{
  inputs,
  ...
}:

{
  imports = with inputs.self.darwinModules; [
    ../darwin-shared.nix
  ];
}
