let
  keys = import ./ssh-keys.nix { };
in
{
  "secret1.age".publicKeys = keys.users ++ keys.systems;
}
