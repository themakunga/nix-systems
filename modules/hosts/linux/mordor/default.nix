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
  flake.nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {};
    modules = [
      commonModules.settings
      sops-nix.nixosModules.sops

      nixosModules.boot-loader
      {
        networking.hostName = "steamdeck";

        services.openssh.enable = true;

        fileSystems = {
          "/" = {
            device = "/dev/disk/by-id/[Partition ID]";
            fsType = "ext4";
          };
          "/opt" = {
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
