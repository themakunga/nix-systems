{
  self,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nixpkgs nixos-hardware sops-nix secrets;
  inherit (self) commonModules;
in {
  flake.nixosConfigurations.sd-image = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      sops-nix.nixosModules.sops
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      nixos-hardware.nixosModules.raspberry-pi-5
      commonModules.state-version
      {
        networking.hostName = "sdimage-install";
        nixpkgs = {
          buildPlatform = "x86_64-linux";
          hostPlatform = "aarch64-linux";
        };

        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
          };
        };

        users.users.root.openssh.authorizedKeys.keys = [
          (builtins.readFile "${secrets}/public-keys/outer-heaven.pub")
        ];

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        sdImage = {
          firmwareSize = 512;
          compressImage = true;
        };

        image.fileName = "sd-image-aarch64-generic.img";

        environment.systemPackages = with inputs.nixpkgs.legacyPackages.aarch64-linux; [
          git
          curl
          disko
        ];

        hardware.deviceTree.enable = true;

        boot = {
          kernelParams = ["pcie_aspm=off"];
          initrd = {
            availableKernelModules = lib.mkForce [
              "usbhid"
              "usb_storage"
              "vc4"
              "pcie_brcmstb"
              "nvme"
            ];
            includeDefaultModules = false;
          };
          loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
          };
        };
      }
    ];
  };
}
