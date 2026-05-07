{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    ;
in
{
  flake.nixosModules.boostrap =
    {
      system,
      hardwareModules,
      hostname,
      authorizedKeys,
      extraModules ? [ ],

    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArfs = { inherit inputs; };
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

        hardwareModules

        self.commonModules.state-version

        {
          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "yes";
          };

          users.users.root.openssh.authorizedKets.keys = [
            authorizedKeys
          ];

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

          sdImage = {
            compressImage = true;
            imageName = "${hostname}-sd_image-aarch64.img";
          };

          environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
            git
            curl
            disko
          ];
        }
      ]
      ++ extraModules;
    };
}
