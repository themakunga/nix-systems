# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Host: aperture-bootstrap (Imagen SD efímera para instalación)
# =========================================================
{
  self,
  inputs,
  ...
}: let
  inherit (inputs) nixpkgs nixos-hardware;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.aperture-bootstrap = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "aperture-bootstrap";
    };

    modules =
      [
        nixos-hardware.nixosModules.raspberry-pi-5
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (mkBundle {
        commonModules = [
          "arch.nixos.rpi"
          "authorized-keys"
          "network"
        ];
        nixosModules = [
          "wifi"
        ];
        rpiModules = [
          "common"
          "hardware-rpi5"
          "sd-image"
        ];
      })
      ++ [
        # 👇 ARREGLO: Convertimos este bloque en una función de módulo de NixOS
        ({
          config,
          pkgs,
          lib,
          ...
        }: {
          networking.hostName = "aperture-bootstrap";

          sops = {
            defaultSopsFile = "${inputs.secrets}/common.yaml";
            validateSopsFiles = false;
            age.keyFile = "/etc/age/keys.txt";
          };

          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "yes";
          };

          my.authorizedKeys = {
            enable = true;
            assignTo = ["root"];
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfrS5Ps9OxiIKgMJo718RbJ7Lwaijwt3g0lEBb8mhCt nicolas@Nicolass-MacBook-Pro.local"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvc7ExxEKPdvwtfa701VyQbrZWUGPCmvFjSAGoqRc7V nmartinezv@icloud.com"
            ];
          };

          system.stateVersion = "26.05";

          sdImage = {
            compressImage = true;

            # mkForce reemplaza por completo el script de sd-image-aarch64.nix,
            # que no tiene soporte para Pi5. Reconstruimos todo manualmente:
            # Pi3/4 igual que nixpkgs + Pi5 con boot directo via EEPROM (sin u-boot,
            # que no existe para Pi5 en nixpkgs 26.05).
            populateFirmwareCommands = lib.mkForce ''
              # ── Firmware base (Pi 3 / 4 compatible) ─────────────────────────
              (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && \
                cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/ 2>/dev/null || true)

              # ── Pi 3 / Pi 0-2 ────────────────────────────────────────────────
              cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2710-rpi-3-b.dtb      firmware/
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2710-rpi-3-b-plus.dtb firmware/
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2710-rpi-zero-2.dtb   firmware/
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2710-rpi-zero-2-w.dtb firmware/

              # ── Pi 4 ─────────────────────────────────────────────────────────
              cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
              cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin                         firmware/
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb      firmware/
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-400.dtb      firmware/
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4.dtb      firmware/
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4s.dtb     firmware/

              # ── Pi 5 (BCM2712) ───────────────────────────────────────────────
              cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/armstub8-2712.bin        firmware/
              cp ${config.boot.kernelPackages.kernel}/dtbs/broadcom/bcm2712-rpi-5-b.dtb firmware/

              # Overlays (incluye nvme.dtbo para el HAT NVMe)
              mkdir -p firmware/overlays
              cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/. firmware/overlays/

              # Kernel NixOS + initrd en la partición FAT para boot directo EEPROM
              cp ${config.system.build.toplevel}/kernel firmware/kernel-pi5.bin
              cp ${config.system.build.toplevel}/initrd firmware/initrd-pi5.img

              # cmdline.txt: leído por el EEPROM del Pi5 en boot directo
              echo "root=LABEL=NIXOS_SD rootfstype=ext4 rootwait console=ttyAMA10,115200 console=tty0 init=${config.system.build.toplevel}/init" \
                > firmware/cmdline.txt

              # ── config.txt ───────────────────────────────────────────────────
              cat > firmware/config.txt << 'CONFIGEOF'
              [pi3]
              kernel=u-boot-rpi3.bin
              core_freq=250

              [pi02]
              kernel=u-boot-rpi3.bin

              [pi4]
              kernel=u-boot-rpi4.bin
              enable_gic=1
              armstub=armstub8-gic.bin
              disable_overscan=1
              arm_boost=1

              [cm4]
              otg_mode=1

              [pi5]
              armstub=armstub8-2712.bin
              kernel=kernel-pi5.bin
              initramfs initrd-pi5.img followkernel
              dtparam=pciex1_gen=3
              dtoverlay=nvme
              dtoverlay=vc4-kms-v3d-pi5

              [all]
              arm_64bit=1
              enable_uart=1
              avoid_warnings=1
              CONFIGEOF
            '';
          };
        })
      ];
  };
}
