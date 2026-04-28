# Raspberry pi 5

{ inputs, ... }:
let
  inherit (inputs) nixpkgs sops-nix secrets;
in
{
  flake = {
    nixosConfigurations.zeke = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit secrets; };
      modules = [
        sops-nix.nixosModules.sops
      ];
    };

    packages.zeke = nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          network = {
            hostName = "zeke.local";
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
            imageName = "zeke-sd-image-aarch64.img";
          };
        }
      ];
    };
  };
}
