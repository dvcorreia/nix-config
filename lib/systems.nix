{
  nixpkgs,
}:

let
  supportedSystems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  # helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'
  forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

  # nixpkgs instantiated for supported system types
  nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
in
{
  inherit supportedSystems forAllSystems nixpkgsFor;
}
