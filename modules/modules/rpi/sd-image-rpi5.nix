# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# SD image configuration for Raspberry Pi 5 (EEPROM direct boot, no U-Boot).
# The Pi 5 EEPROM reads config.txt from the FAT32 partition and loads the kernel
# directly. populateFirmwareCommands replaces the sd-image-aarch64.nix default
# with a Pi 5-specific firmware layout (DTBs, kernel-pi5.img, config.txt).
#
# generic-extlinux-compatible is intentionally left enabled: disabling it makes
# populateCmd undefined, and mergeDefinitions evaluates all definitions during
# normalization — including the aarch64 one that references populateCmd — even
# when our mkForce definition has higher priority. populateRootCommands is
# overridden to skip calling populateCmd; the Pi 5 EEPROM ignores extlinux.
{inputs, ...}: let
  inherit (inputs) nixpkgs;
in {
  flake.rpiModules.sd-image-rpi5 = {
    lib,
    config,
    pkgs,
    ...
  }: let
    # Generado como store path para evitar problemas de indentación con heredocs
    # dentro de strings Nix (el terminador CONFIGEOF quedaría con 2 espacios
    # de indentación y bash no lo reconocería como fin del heredoc).
    configTxt = pkgs.writeText "rpi5-config.txt" ''
      [pi5]
      kernel=kernel-pi5.img
      initramfs initrd-pi5.img followkernel
      dtparam=pciex1_gen=3
      # Requerido para el M.2 HAT+ oficial de Raspberry Pi.
      # Sin este overlay el enlace PCIe queda caído (link down) y el NVMe no aparece.
      dtoverlay=pciex1-compat-pi5,no-mip
      dtoverlay=vc4-kms-v3d-pi5

      [all]
      arm_64bit=1
      enable_uart=1
      avoid_warnings=1
    '';
  in {
    imports = [
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];

    boot = {
      supportedFilesystems = lib.mkForce ["ext4" "vfat"];

      initrd = {
        # Usar stage-1 (shell) en lugar de systemd initrd.
        # sd-image-aarch64.nix habilita systemd initrd en nixpkgs reciente, lo que
        # genera la unidad sysroot-run.mount que falla en RPi5 si el root device
        # no está listo a tiempo. El stage-1 clásico maneja el montaje directamente
        # sin depender de unidades systemd, eliminando ese error por completo.
        systemd.enable = lib.mkForce false;

        includeDefaultModules = false;
        # mkForce necesario aquí: sd-image-aarch64.nix (que importamos) añade módulos
        # genéricos de aarch64 como dw-hdmi, rockchip_*, etc. que NO existen en el
        # kernel RPi y rompen el build (makeModulesClosure los busca y no los encuentra).
        # Con mkForce descartamos esa lista genérica y controlamos exactamente qué
        # módulos entran en el initrd de la imagen SD del Pi 5.
        #
        # clk-rp1 y rp1/rp1_pci son builtin en el kernel RPi — no necesitan estar aquí.
        availableKernelModules = lib.mkForce [
          "usbhid"
          "usb_storage"
          "xhci_pci"
          "nvme"
          "pcie_brcmstb" # PCIe bridge → necesario para llegar al chip RP1
          "reset-raspberrypi"
          "mmc_block" # bloque SD → imprescindible para montar NIXOS_SD
        ];

        # mkOverride 49 supera el mkForce (50) de hardware-rpi5.nix que fuerza solo ["nvme"].
        # mmc_block DEBE cargarse activamente en el initrd; sin él el kernel no puede
        # acceder a NIXOS_SD y el montaje del root falla.
        kernelModules = lib.mkOverride 49 ["mmc_block"];
      };
    };

    hardware = {
      deviceTree.enable = true;
      enableRedistributableFirmware = true;
    };

    fileSystems."/" = {
      device = lib.mkForce "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

    sdImage = {
      compressImage = true;
      firmwareSize = 256;

      populateRootCommands = lib.mkForce ''
        mkdir -p ./files/boot
      '';

      populateFirmwareCommands = lib.mkForce ''
        mkdir -p firmware

        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && \
          cp bootcode.bin fixup*.dat start*.elf \
          $NIX_BUILD_TOP/firmware/ 2>/dev/null || true)
        chmod -R +w firmware/

        cp -r ${config.system.build.toplevel}/dtbs/broadcom/* \
          firmware/ 2>/dev/null || true
        cp -r ${config.system.build.toplevel}/dtbs/* \
          firmware/ 2>/dev/null || true

        mkdir -p firmware/overlays
        cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/. \
          firmware/overlays/
        chmod -R +w firmware/overlays/

        cp ${config.system.build.toplevel}/kernel firmware/kernel-pi5.img
        cp ${config.system.build.toplevel}/initrd firmware/initrd-pi5.img

        # Una sola línea: el firmware RPi5 solo lee la primera línea de cmdline.txt.
        # El string multi-línea anterior causaba que console= e init= se perdieran.
        printf '%s\n' \
          "root=LABEL=NIXOS_SD rootfstype=ext4 rootwait console=ttyAMA10,115200 console=tty0 init=${config.system.build.toplevel}/init" \
          > firmware/cmdline.txt

        cp ${configTxt} firmware/config.txt
      '';
    };
  };
}
