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
  flake.nixosConfigurationsd.numenor = nixpkgs.lib.nixosSystem {
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
        image.filename = "nixos-numenor.img";
        networking.hostName = "numenor";
      }
      (
        {
          lib,
          ...
        }:
        {

          boot = {
            initrd = {
              availableKernelModules = [
                "pcie_brcmrd"
                "nvme"
              ];
            };
          };

        }
      )
      profileModules.isildur
    ];
  };
}
