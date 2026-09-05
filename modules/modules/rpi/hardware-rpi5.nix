# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: hardware-rpi5.nix
# Path: ./modules/modules/rpi/hardware-rpi5.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{lib, ...}: {
  flake.rpiModules.hardware-rpi5 = {
    modulesPath,
    pkgs,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      # rootwait: espera a que el PCIe/NVMe termine de inicializar antes de
      # intentar montar root. Sin esto hay race condition → unknown-block(0,0).
      kernelParams = ["pcie_aspm=off" "rootwait"];
      initrd = {
        includeDefaultModules = false;
        # mkForce necesario: nixos-hardware.raspberry-pi-5 y not-detected.nix añaden
        # módulos que NO existen en el kernel RPi (ej: tpm-crb), lo que rompe
        # makeModulesClosure con "Module not found". Controlamos la lista exacta aquí.
        #
        # clk-rp1, rp1/rp1_pci, nvme, pcie_brcmstb, reset-raspberrypi son BUILTIN
        # en el kernel RPi 6.x — no necesitan estar en availableKernelModules.
        # tpm-crb NO existe en el kernel RPi → excluido explícitamente con mkForce.
        #
        # sd-image-rpi5.nix tiene su propio mkForce (misma prioridad 50) que agrega
        # mmc_block para boot desde SD; ambas listas se concatenan sin conflicto.
        availableKernelModules = lib.mkForce [
          "usbhid"
          "usb_storage"
          "xhci_pci"
          "nvme"
          "pcie_brcmstb"
          "reset-raspberrypi"
        ];
        kernelModules = lib.mkForce ["nvme"];
      };
    };

    hardware = {
      enableRedistributableFirmware = true;
      deviceTree.filter = "bcm2712-rpi-5-b.dtb";

      raspberry-pi = {
        # Instala firmware del RPi (DTBs, overlays, config.txt) en /boot/firmware
        # en cada nixos-rebuild switch.
        firmware = {
          enable = true;
          # U-Boot DESACTIVADO: boot directo EEPROM → kernel NixOS.
          # Con uboot.enable=true, el EEPROM carga u-boot.bin → U-Boot intenta
          # reinicializar PCIe para leer extlinux.conf desde NVMe → falla porque
          # el PCIe ya fue inicializado por el EEPROM y U-Boot no puede re-init.
          # Resultado: logo de submarino colgado.
          # Con uboot.enable=false + kernel=nixos-kernel.img, el EEPROM carga el
          # kernel NixOS directamente desde la partición FAT32 sin intermediarios.
          uboot.enable = false;
        };

        configtxt.settings = {
          all = {
            # Nombre fijo del kernel en FAT32. El activation script nvme-direct-boot
            # copia /run/current-system/kernel aquí en cada nixos-rebuild switch.
            # NOTA: 'initramfs' NO se puede declarar aquí — el módulo configtxt
            # genera 'initramfs=...' con '=' pero el EEPROM requiere 'initramfs ...'
            # sin '='. El activation script inserta la línea correcta.
            kernel = "nixos-kernel.img";
          };
          "pi5" = {
            arm_freq = 2400;
            gpu_freq = 800;
            # PCIe Gen 3 en el conector externo del RPi5 (requerido para M.2 HAT+).
            dtparam = ["pciex1_gen=3"];
            # Overlays para M.2 HAT+ oficial y GPU VC4 Wayland.
            # pciex1-compat-pi5,no-mip: mantiene el enlace PCIe activo tras reinit.
            dtoverlay = ["pciex1-compat-pi5,no-mip" "vc4-kms-v3d-pi5"];
          };
        };
      };
    };

    # machine-id: systemd requiere este archivo para crear sesiones logind.
    # Sin él, pam_systemd falla en Varlink → greetd no puede abrir sesión → Hyprland no arranca.
    # nixos-install no lo crea automáticamente en el contexto chroot del RPi.
    # Este script es idempotente: no lo toca si ya existe y está poblado.
    system.activationScripts.machine-id-setup = lib.stringAfter ["etc"] ''
      if [ ! -s /etc/machine-id ]; then
        echo "machine-id-setup: inicializando /etc/machine-id..."
        ${pkgs.systemd}/bin/systemd-machine-id-setup
      fi
    '';

    # Actualiza archivos de boot en /boot/firmware en cada nixos-rebuild switch.
    # Sin esto, el EEPROM cargaría el kernel/initrd de la generación anterior
    # y el init path en cmdline.txt quedaría desactualizado → kernel panic.
    #
    # Ejecuta DESPUÉS de raspberry-pi-firmware (que ya copió config.txt a FAT32).
    system.activationScripts.nvme-direct-boot = lib.stringAfter ["raspberry-pi-firmware"] ''
      FIRMWARE="/boot/firmware"
      if mountpoint -q "$FIRMWARE"; then

        # Resolver el path del NUEVO sistema que se está activando.
        # $0 es el script 'activate' del nuevo sistema (en su store path).
        # Esto funciona tanto en nixos-install (chroot) como en nixos-rebuild switch,
        # sin depender de /run/current-system (que aún apunta al sistema anterior
        # cuando corre este script).
        SYSTEM=$(${pkgs.coreutils}/bin/dirname "$0")
        if [ ! -e "$SYSTEM/kernel" ]; then
          # Fallback: si el script no corre desde el store path esperado
          if [ -L /run/current-system ]; then
            SYSTEM=$(${pkgs.coreutils}/bin/readlink -f /run/current-system)
          elif [ -e /nix/var/nix/profiles/system ]; then
            SYSTEM=$(${pkgs.coreutils}/bin/readlink -f /nix/var/nix/profiles/system)
          else
            echo "nvme-direct-boot: no se encontró el sistema, skip" >&2
            exit 0
          fi
        fi

        # 1. Insertar 'initramfs nixos-initrd.img followkernel' en config.txt.
        #    El módulo configtxt genera 'initramfs=...' con '=' — sintaxis incorrecta.
        #    El EEPROM requiere 'initramfs <file> followkernel' sin '='.
        #    Idempotente: solo inserta si no existe la línea.
        if ! ${pkgs.gnugrep}/bin/grep -q '^initramfs ' "$FIRMWARE/config.txt" 2>/dev/null; then
          ${pkgs.gnused}/bin/sed -i \
            '/^kernel=nixos-kernel.img/a initramfs nixos-initrd.img followkernel' \
            "$FIRMWARE/config.txt"
        fi

        # 2. Copiar kernel e initrd (atómico vía rename).
        ${pkgs.coreutils}/bin/cp "$SYSTEM/kernel" "$FIRMWARE/nixos-kernel.img.tmp"
        ${pkgs.coreutils}/bin/mv "$FIRMWARE/nixos-kernel.img.tmp" "$FIRMWARE/nixos-kernel.img"
        ${pkgs.coreutils}/bin/cp "$SYSTEM/initrd" "$FIRMWARE/nixos-initrd.img.tmp"
        ${pkgs.coreutils}/bin/mv "$FIRMWARE/nixos-initrd.img.tmp" "$FIRMWARE/nixos-initrd.img"

        # 3. Regenerar cmdline.txt.
        #    root=UUID evita ambigüedad si hay SD y NVMe con el mismo label.
        ROOT_UUID=$(${pkgs.util-linux}/bin/findmnt -n -o UUID /)
        INIT=$(${pkgs.coreutils}/bin/readlink -f "$SYSTEM/init")
        ${pkgs.coreutils}/bin/printf '%s\n' \
          "init=$INIT pcie_aspm=off rootwait root=UUID=$ROOT_UUID loglevel=4 lsm=landlock,yama,bpf" \
          > "$FIRMWARE/cmdline.txt"

        echo "nvme-direct-boot: OK — $INIT"
      else
        echo "nvme-direct-boot: $FIRMWARE no montado — boot files NO actualizados" >&2
      fi
    '';
  };
}
