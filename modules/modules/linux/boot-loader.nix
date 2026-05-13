{
  flake.nixosModules.boot-loader = {
    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = false;
    };
  };
}
