{inputs, ...}: let
  inherit (inputs) nixosModules;
in {
  flake.rpiModules = {
    boot-loader = {
      boot.loader = {
        grub.enable = false;
        systemd-boot.enable = false;
        efi.canTouchEfiVariables = false;
      };
    };

    systemPackages = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        pciutils
      ];
    };
    boot = {lib, ...}: let
      inherit (lib) mkForce;
    in {
      boot = {
        kernelParams = ["pcie_aspm=off"];
        initrd = {
          availableKernelModules = mkForce [
            "usbhid"
            "usb_storage"
            "vc4"
            "mmc_block"
          ];
          includeDefaultModules = false;
        };
      };
    };
    config = {
      pkgs,
      lib,
      inputs,
      ...
    }: let
      inherit (inputs) nixpkgs secrets;
      inherit (lib) mkDefault;
    in {
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
        device = mkDefault "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };

      services.openssh = {
        enable = true;
      };

      users.users.root.openssh.authorizedKeys.keys = [
        (builtins.readFile "${secrets}/public_keys/gondor.pub")
        (builtins.readFile "${secrets}/public_keys/rohan.pub")
        (builtins.readFile "${secrets}/public_keys/eregoin.pub")
        (builtins.readFile "${secrets}/public_keys/mirkwood.pub")
        (builtins.readFile "${secrets}/public_keys/numenor.pub")
        (builtins.readFile "${secrets}/public_keys/rivendell.pub")
        (builtins.readFile "${secrets}/public_keys/hobbitton.pub")
        (builtins.readFile "${secrets}/public_keys/isengard.pub")
        (builtins.readFile "${secrets}/public_keys/mordor.pub")
      ];

      environment.systemPackages = with pkgs; [
        git
        curl
        disko
      ];
    };
    builder = {
      modules = [
        nixosModules.stateVersion
      ];
    };
  };
}
