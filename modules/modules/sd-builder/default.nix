{inputs, ...}: let
  inherit
    (inputs)
    nixpkgs
    ;
in {
  flake.nixosModules.sd-builder = {config}:
    nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          network.hostName = "${config.name}";
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
            compressImage = true;
            imageName = "${config.name}-sh-image-aarch64.img";
          };
        }
      ];
    };
}
