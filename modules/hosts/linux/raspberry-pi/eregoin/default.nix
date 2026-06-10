{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    nixos-hardware
    ;
  inherit (self)
    nixosModules
    profileModules
    ;
in
{
  flake.nixosConfigurationsd.eregoin = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      nixosModules.stateVersion
      nixosModules.rpi.config
      nixosModules.rpi.builder
      nixos-hardware.nixosModules.raspberry-pi-5
      nixosModules.rpi.sdImage
      nixosModules.rpi.systemPackages
      nixosModules.rpi.boot
      nixosModules.wifi
      {
        image.filename = "nixos-eregoin.img";
        networking.hostName = "eregoin";
      }
      (
        {
          lib,
          ...
        }:
        {

          boot = {
            initrd = {
              availableKernelModules = lib.mkForce [
                "usb_storage"
                "pcie_brcmstb"
                "nvme"
                "reset_raspberrypi"
              ];
            };
          };

        }
      )
      profileModules.celebimbor
    ];
  };
}
