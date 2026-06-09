{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    disko
    sops-nix
    nixos-hardware
    ;
  inherit (self)
    nixosModules
    commonModules
    ;
in
{
  flake.nixosConfigurationsd.eregoin = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      nixosModules.rpi-config
      nixos-hardware.nixosModules.raspberry-pi-5
      (
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          netrworking = {
            hostName = "eregoin";
          };

          environment.systemPackages = with pkgs; [
            pciutils
          ];

          boot = {
            kernelParams = [ "pcie_aspm=off" ];
            initrd = {
              availableKernelModules = lib.mkForce [
                "usb_storage"
                "vc4"
                "pcie_brcmstb"
                "nvme"
                "mmc_block"
                "reset_raspberrypi"
              ];
              includeDefaultModules = false;
            };
          };
          image = {
            fileName = "nixos-eregoin.img";
          };

          sdImage = {
            firmwareSize = 512;
            compressImage = true;

            populateFirmwareCommeands =
              let
                inherit (pkgs) raspberrypifw writeText;
                inherit (config.system.build) kernel initialRamdisk toplevel;
                inherit (lib) mkForce;

                configTxt = writeText "config.txt" ''
                  [pi5]
                  arm_64bit=1
                  enable_uart=1

                  dtparam=pciex1
                  dtparam=nvme

                  kernel=kernel.img
                  inirramfs initrd.img followkernel
                '';
                cmdLineTxt = writeText "cmdline.txt" ''
                  console=ttyAMA0,115200 console=tty1 root=/dev/disk/by-label/NIXOS_SD rootwait rootfstype=ext4 init=${toplevel}/init loglevel=7
                '';
              in
              mkForce ''
                rm -rf firmware/*
                cp -r ${raspberrypifw}/shared/raspberrypi/boot/* firmware/
                chmod -R +w firmware/
                cp -f ${kernel}/Image firmware/kermel.img
                cp -f ${initialRamdisk}/initrd firmware/initrd.img
                cp -f ${configTxt} firmware/config.txt
                cp -f ${cmdLineTxt} firmware/cmdline.txt
              '';

          };

        }
      )
    ];
  };
}
