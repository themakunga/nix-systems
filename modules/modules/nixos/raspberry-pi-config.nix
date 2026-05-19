{
  flake.nixosModules.rpi-config = {
    pkgs,
    lib,
    inputs,
    ...
  }: let
    inherit (inputs) nixpkgs secrets;
  in {
    system.stateVersion = "25.11";

    nix.settings.experimental-features = [
      "nix-command"
      "nix-flakes"
    ];

    imports = [
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];

    nixpkgs = {
      buildPlatform = "x86_64-linux";
      hostPlatform = "aarch64-linux";
    };

    boot.loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      efi.canTouchEfiVariables = false;
    };

    hardware.deviceTree.enable = true;

    fileSystems."/" = {
      device = lib.mkDefault "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    users.users.root.openssh.authorizedKeys.keys = [
      (builtins.readFile "${secrets}/public-keys/outer-heaven.pub")
      (builtins.readFile "${secrets}/public-keys/kanagawa.pub")
      (builtins.readFile "${secrets}/public-keys/motherbase.pub")
      (builtins.readFile "${secrets}/public-keys/wheatley.pub")
      (builtins.readFile "${secrets}/public-keys/glados.pub")
      (builtins.readFile "${secrets}/public-keys/mediaserver.pub")
    ];

    environment.systemPackages = with pkgs; [
      git
      curl
      disko
    ];
  };
}
