# Raspberry pi Zero2
{ inputs, ... }:
let
  inherit (inputs) nixpkgs sops-nix secrets;
in
{
  flake = {
    nixosConfigurations.cornholio = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit secrets; };
      modules = [
        sops-nix.nixosModules.sops
      ];
    };
    packages.cornholio = nixpkgs.lib.nixosSystem {
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
}
