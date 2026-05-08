{
  inputs,
  self,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    sops-nix
    ;
  inherit
    (self)
    nixosModules
    commonModules
    ;
in {
  flake.nixosConfigurations.motherbase = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {};
    modules = [
      commonModules.nix-settings
      commonModules.state-version

      sops-nix.nixosModules.sops
      commonModules.secrets-management

      nixosModules.boot-loader
      {
        networking.hostName = "motherbase";

        services.openssh.enable = true;

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-id/[ID DE PARTICION]";
            fsType = "ext4";
          };
          "/opt" = {
            device = "/dev/disk/by-id/[ID DE PARTICION]";
            fsType = "ext4";
          };
          "/boot" = {
            device = "/dev/disk/by-id/[ID DE PARTICION]";
            fsType = "vfat";
          };
        };
      }
    ];
  };
}
