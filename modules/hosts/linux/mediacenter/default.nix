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
  flake.nixosConfigurations.mediacenter = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {};
    modules = [
      commonModules.nix-settings
      commonModules.state-version

      sops-nix.nixosModules.sops
      commonModules.secrets-management

      nixosModules.boot-loader
      {
        networking.hostName = "mediacenter";

        services.openssh.enable = true;

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-id/[Partition ID]";
            fsType = "ext4";
          };
          "/home" = {
            device = "/dev/disk/by-id/[Partition ID]";
            fsType = "ext4";
          };
          "/boot" = {
            device = "/dev/disk/by-id/[Partition ID]";
            fsType = "vfat";
          };
        };
      }
    ];
  };
}
