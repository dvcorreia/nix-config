{
  inputs,
  ...
}:

{
  imports = with inputs.self.darwinModules; [
    ../darwin-shared.nix
    services-ollama
  ];

  services.ollama.enable = true;
}
