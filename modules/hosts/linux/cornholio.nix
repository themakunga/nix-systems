{ inputs, ... }:
let
  inherit (inputs)
    nixpkgs
    sops-nix
    secrets
    dotfiles
    ;
in
{
  flake = {
    nixosConfigurations.cornholio = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit secrets dotfiles; };
      modules = [
        sops-nix.nixosModules.sops
        { boot.loader.grub.enable = false; }
      ];
    };
    nixosModules.cornholio = nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          network.hostName = "cornholio.local";
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
            imageName = "cornholio-sd-image-aarch64.img";
          };
        }
      ];

    };
  };
}
