{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    disko
    sops-nix
    nixos-hardware
    ;
  inherit
    (self)
    nixosModules
    commonModules
    ;
in {
  flake = {
    nixosConfigurations = {
      glaDOS = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          inherit (inputs) nixpkgs secrets;
        };
        modules = [
          {nixpkgs.hostPlatform = "aarch64-linux";}
          nixos-hardware.nixosModules.raspberry-pi-5
          commonModules.settings
          disko.nixosModules.disko
          nixosModules.glaDOS-disk

          sops-nix.nixosModules.sops
          {
            networking.hostName = "glaDOS";

            boot = {
              loader = {
                grub.enable = false;
                generic-extlinux-compatible.enable = true;
              };
            };

            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "no";
            };
          }
        ];
      };
      glaDOS-build = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          nixosModules.rpi-config
          nixos-hardware.nixosModules.raspberry-pi-5

          (
            {
              config,
              pkgs,
              lib,
              ...
            }: {
              networking.hostName = "glaDOS-installer";
              environment.systemPackages = [pkgs.pciutils];

              boot = {
                kernelParams = ["pcie_aspm=off"];
                initrd = {
                  availableKernelModules = lib.mkForce [
                    "usbhid"
                    "usb_storage"
                    "vc4"
                    "pcie_brcmstb" # PCIe (RPi 5)
                    "nvme" # Discos NVMe
                    "mmc_block" # Lector de SD
                    "reset_raspberrypi"
                  ];
                  includeDefaultModules = false;
                };
              };

              image.fileName = "nixos-GlaDOS-boot.nix";

              sdImage = {
                firmwareSize = 512;
                compressImage = true;

                populateFirmwareCommands = let
                  configTxt = pkgs.writeText "config.txt" ''
                    [pi5]
                    arm_64bit=1
                    enable_uart=1

                    # Encendemos el bus PCIe para que nix-anywhere detecte el SSD NVMe
                    dtparam=pciex1
                    dtparam=nvme

                    # Instruimos a la Pi a arrancar NixOS directo
                    kernel=kernel.img
                    initramfs initrd.img followkernel
                  '';

                  cmdlineTxt = pkgs.writeText "cmdline.txt" ''
                    console=ttyAMA0,115200 console=tty1 root=/dev/disk/by-label/NIXOS_SD rootwait rootfstype=ext4 init=${config.system.build.toplevel}/init loglevel=7
                  '';
                in
                  lib.mkForce ''
                    rm -rf firmware/*
                    cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/* firmware/
                    chmod -R +w firmware/
                    cp -f ${config.system.build.kernel}/Image firmware/kernel.img
                    cp -f ${config.system.build.initialRamdisk}/initrd firmware/initrd.img
                    cp -f ${configTxt} firmware/config.txt
                    cp -f ${cmdlineTxt} firmware/cmdline.txt
                  '';
              };
            }
          )
        ];
      };
    };
  };
}
