# Raspberry pi Zero2
{ self, inputs, ... }:

let
  inherit (inputs)
    nixpkgs
    sops-nix
    secrets
    ;
in
{
  flake = {
    nixosConfigurations = {
      "cornholio" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit secrets; };
        modules = [
          sops-nix.nixosModules.sops
          { boot.loader.grub.enable = false; }
        ];
      };
      "glaDOS" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit secrets; };
        modules = [
          sops-nix.nixosModules.sops
          { boot.loader.grub.enable = false; }
        ];
      };
      "motherbase" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets; };
        modules = [
          sops-nix.nixosModules.sops
        ];
      };
      "lab42" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets; };
        modules = [
          sops-nix.nixosModules.sops
        ];
      };
    };
    buildImages = {
      "cornholio" = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          {
            network = {
              hostName = "cornholio.local";
            };

            boot.supportedFileSystem = nixpkgs.lib.mkForce [
              "btrfs"
              "reiserfs"
              "vfat"
              "f2fs"
              "xfs"
              "ntfs"
              "cifs"
            ];
            sdImage = {
              compresImage = true;
              imageName = "cornholio-sd-image-aarch64.img";
            };
          }
        ];
      };
    };
  };
}
