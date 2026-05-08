{
  flake.nixosModules.boot-loader = {
    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
