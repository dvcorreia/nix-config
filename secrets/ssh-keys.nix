_: rec {
  yubikey1-ed25519-sk = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOFxsrj7vbKLYKqdApEGMbJWoGl77eS+ACQC/vKKWHYJAAAABHNzaDo= dv_correia@hotmail.com";

  dvcorreia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4eQf9kO/8ylzg+wDmNSbe5ubhJ23XvmcKGbYKlPhw5 dv_correia@hotmail.com";
  users = [ dvcorreia ];

  macbook-m3-pro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKLdXLVtZ/HGcNTAKeE/FfCPDrS5sThJoRVy3VWC8zQB root@macbook-m3-pro";
  proart-7950x = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIwdsk5RrvGq/QOVASenS4SWR6lTjr9gXPpivcjCijHl root@proart-7950x";
  sines = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzcKuPWDJfNCjmEAoRmIA0EH1Mcwuwn88Cjp029t8sw root@sines";
  systems = [
    macbook-m3-pro
    proart-7950x
    sines
  ];
}
