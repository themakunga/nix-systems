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

      # Nota: Require nixos-hardware para funcionar completamente
      raspberry-pi."5" = {
        fkms-3d.enable = true;
        overclock = {
          arm-freq = 2400; # MHz
          gpu-freq = 800; # MHz
        };
      };
    };
  };
}
