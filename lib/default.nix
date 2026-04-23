{ inputs }:
let
  inherit (inputs)
    nixpkgs
    nix-darwin
    sops-nix
    secrets
    nix-homebrew
    ;

in
{

  mkDarwin =
    system: modules:
    nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit secrets; };
      modules = [
        sops-nix.darwinModules.sops
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            autoMigrate = true;
          };
        }
      ]
      ++ modules;
    };

  mkNixOS =
    system: modules:
    nixpkgs.lib.nixpkgsSystem {
      inherit system;
      specialArgs = { inherit secrets; };
      modules = [
        sops-nix.nixosModules.sops
      ]
      ++ modules;
    };

  mkSDImage =
    system: hostname: hostModule:
    nixpkgs.lib.nixpkgsSystem {
      inherit system;
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        {
          networking.hostName = hostname;

          boot.supportedFilesystems = nixpkgs.lib.mkForce [
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
            imageName = "${hostname}-sd-image.img";
          };
        }
      ];

    };
}
