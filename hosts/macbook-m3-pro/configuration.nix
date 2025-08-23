{
  inputs,
  ...
}:

{
  imports = with inputs.self.nixosModules; [
    ../darwin-shared.nix
    services-ollama
  ];

  services.ollama.enable = true;
}
