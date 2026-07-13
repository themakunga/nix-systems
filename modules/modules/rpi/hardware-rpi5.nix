{
  flake.rpiModules.hardware-rpi5 = {modulesPath, ...}: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      kernelParams = ["pcie_aspm=off"];
      initrd = {
        availableKernelModules = [
          "usbhid"
          "usb_storage"
          "xhci_pci"
          "nvme"
          "pcie_brcmstb"
          "reset-raspberrypi"
        ];
        kernelModules = ["nvme"];
      };
    };

    hardware = {
      enableRedistributableFirmware = true;
      deviceTree.filter = "bcm2712-rpi-5-b.dtb";

      # Inyección directa de parámetros de hardware
      raspberry-pi.configtxt = ''
        # Overclocking CPU y GPU
        arm_freq=2400
        gpu_freq=800

        # Aceleración por hardware 3D
        # (En la RPi 5 se recomienda KMS completo en lugar del antiguo FKMS)
        dtoverlay=vc4-kms-v3d-pi5
      '';
    };
  };
}
