{ nixpkgsFor, inputs }:

{
  x86_64-linux =
    let
      pkgs = nixpkgsFor."x86_64-linux";
    in
    {
      dvcorreia-website = import ./dvcorreia-website.nix { inherit pkgs inputs; };
    };
}
