{
  flake.rpiModules.common = {pkgs, ...}: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    documentation = {
      enable = false;
      nixos.enable = false;
    };

    services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      git
      curl
      disko
      pciurils
    ];

    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = false;
    };
  };
}
