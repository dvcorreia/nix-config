let
  dvcorreia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZLEV54sHhGh8WoYNYztLDl8d9DPKuz07CopwRKPl8K dv_correia@hotmail.com";
  users = [ dvcorreia ];

  macbook-m3-pro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIsWETol5xHJFEZi1v+H1MVCpXnvpm0iIZd3VEmjldSo root@macbook-m3-pro";
  proart-7950x = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwdsk5RrvGq/QOVASenS4SWR6lTjr9gXPpivcjCijHl root@proart-7950x";
  systems = [
    macbook-m3-pro
    proart-7950x
  ];
in
{
  "secret1.age".publicKeys = users ++ systems;
}
