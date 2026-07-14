{ lib, ... }: {
  flake.rpiModules.hardware-rpi5 = { modulesPath, ... }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      kernelParams = ["pcie_aspm=off"];
      initrd = {
        includeDefaultModules = false;
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

      raspberry-pi.configtxt.settings = {
        "pi5" = {
          arm_freq = 2400;
          gpu_freq = 800;
          dtoverlay = "vc4-kms-v3d-pi5";
        };
      };
    };
  };
}
