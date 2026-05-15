{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    nixos-hardware
    sops-nix
    secrets
    ;
  inherit (self) commonModules;
in {
  flake.nixosConfigurations.sd-image = nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = [
      sops-nix.nixosModules.sops
      nixos-hardware.nixosModules.raspberry-pi-5
      commonModules.state-version

      (
        {
          config,
          pkgs,
          lib,
          ...
        }: {
          imports = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];

          # --- ARQUITECTURA ---
          nixpkgs = {
            buildPlatform = "x86_64-linux"; # Compilando desde Mac (Apple Silicon)
            hostPlatform = "aarch64-linux"; # Compilando para Raspberry Pi (ARM64)
          };

          # --- BOOT Y HARDWARE ---
          boot = {
            kernelParams = ["pcie_aspm=off"];
            initrd = {
              availableKernelModules = lib.mkForce [
                # --- USB y Video ---
                "usbhid"
                "usb_storage"
                "vc4"
                # --- PCIe y NVMe ---
                "pcie_brcmstb"
                "nvme"
                # --- Lector MicroSD (AQUÍ ESTÁ EL FIX) ---
                "mmc_block"
                "sdhci"
                "sdhci_pci"
                "sdhci_iproc"
                "sdhci_bcm2835"
                # --- Sistemas de Archivos ---
                "ext4"
                "vfat"
              ];
              includeDefaultModules = false;
            };
            loader = {
              grub.enable = false;
              generic-extlinux-compatible.enable = true;
              efi.canTouchEfiVariables = false;
            };
          };

          hardware.deviceTree.enable = true;

          # --- GENERACIÓN DE LA IMAGEN SD ---
          sdImage = {
            imageName = "nixos-rpi5-anywhere.img";
            firmwareSize = 512;
            compressImage = true; # Puedes cambiar a 'false' si quieres acelerar las pruebas locales

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
                # 1. Limpiamos cualquier rastro de firmware antiguo genérico
                rm -rf firmware/*

                # 2. Copiamos el firmware base oficial de la Raspberry Pi
                cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/* firmware/

                # 3. FIX: Damos permisos de escritura a la carpeta para que Nix no se queje de permisos
                chmod -R +w firmware/

                # 4. Extraemos el Kernel y Ramdisk exactos de tu build de NixOS (forzando sobreescritura con -f)
                cp -f ${config.system.build.kernel}/Image firmware/kernel.img
                cp -f ${config.system.build.initialRamdisk}/initrd firmware/initrd.img

                # 5. Inyectamos nuestros archivos de configuración de arranque
                cp -f ${configTxt} firmware/config.txt
                cp -f ${cmdlineTxt} firmware/cmdline.txt
              '';
          };

          # --- SISTEMA DE ARCHIVOS Y RED ---
          fileSystems."/" = {
            device = "/dev/disk/by-label/NIXOS_SD";
            fsType = "ext4";
          };

          networking.hostName = "sdimage-install";

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

          environment.systemPackages = with pkgs; [
            git
            curl
            pciutils
            disko
          ];
        }
      )
    ];
  };
}
