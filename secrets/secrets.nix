let
  dvcorreia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZLEV54sHhGh8WoYNYztLDl8d9DPKuz07CopwRKPl8K dv_correia@hotmail.com";
  users = [ dvcorreia ];

  macbook-m3-pro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIsWETol5xHJFEZi1v+H1MVCpXnvpm0iIZd3VEmjldSo root@macbook-m3-pro";
  systems = [ macbook-m3-pro ];
in
{
  "secret1.age".publicKeys = users ++ systems;
}
