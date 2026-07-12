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
            "pcie_brcmstb"
            "reset-raspberrypi"
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
      inherit (inputs) nixpkgs;
      inherit (lib) mkDefault mkForce;
    in {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      imports = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      ];

      sdImage.compressImage = true;

      boot = {
        supportedFilesystems = mkForce ["ext4" "vfat"];
        loader = {
          grub.enable = false;
          generic-extlinux-compatible.enable = true;
          efi.canTouchEfiVariables = false;
        };
      };

      hardware = {
        deviceTree.enable = true;
        enableRedistributableFirmware = true;
      };

      fileSystems."/" = {
        device = mkDefault "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };

      services.openssh = {
        enable = true;
      };

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
