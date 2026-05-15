{
  self,
  inputs,
  lib,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    nixos-hardware
    sops-nix
    secrets
    config
    ;
  inherit (self) commonModules;
in {
  flake.nixosConfigurations.sd-image = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      sops-nix.nixosModules.sops
      nixos-hardware.nixosModules.raspberry-pi-5
      commonModules.state-version
      (
        {pkgs, ...}: {
          imports = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];

          boot = {
            kernelParams = ["pcie_aspm=off"];
            initrd = {
              availableKernelModules = lib.mkForce [
                "usbhid"
                "usb_storage"
                "vc4"
                "pcie_brcmstb"
                "nvme"
              ];
              includeDefaultModules = false;
            };
            loader = {
              grub.enable = false;
              generic-extlinux-compatible.enable = true;
              efi.canTouchEfiVariables = false;
            };
          };

          image.fileName = "nixos-rpi-anywhere.img";

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
                console=ttyAMA0,115200 console=tty1 root=/dev/disk/by-label/NIXOS_SD rootfstype=ext4 init=${config.system.build.toplevel}/init loglevel=7
              '';
            in
              lib.mkForce ''
                # 1. Limpiamos cualquier rastro de firmware antiguo (U-Boot RPi4)
                rm -rf firmware/*

                # 2. Copiamos el firmware base oficial de la Raspberry Pi
                cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/* firmware/

                # 3. Extraemos el Kernel y Ramdisk exactos de tu build de NixOS
                cp ${config.system.build.kernel}/Image firmware/kernel.img
                cp ${config.system.build.initialRamdisk}/initrd firmware/initrd.img

                # 4. Inyectamos nuestros archivos de arranque
                cp ${configTxt} firmware/config.txt
                cp ${cmdlineTxt} firmware/cmdline.txt
              '';
          };

          fileSystems."/" = {
            device = "/dev/disk/by-label/NIXOS_SD";
            fsType = "ext4";
          };

          networking.hostName = "sdimage-install";

          nixpkgs = {
            buildPlatform = "x86_64-linux";
            hostPlatform = "aarch64-linux";
          };

          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "yes";
          };

          users.users.root.openssh.authorizedKeys.keys = [
            (builtins.readFile "${secrets}/public-keys/outer-heaven.pub")
          ];

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

          environment.systemPackages = with inputs.nixpkgs.legacyPackages.aarch64-linux; [
            git
            curl
            pciutils
            disko
          ];

          hardware.deviceTree.enable = true;
        }
      )
    ];
  };
}
