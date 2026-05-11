{
  inputs,
  self,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    ;
in {
  flake.builderModules.bootstrap = {
    system,
    hardware,
    hostname,
    authorizedKeys,
    extraModules ? [],
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules =
        [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

          hardware

          self.commonModules.state-version

          {
            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "yes";
            };

            users.users.root.openssh.authorizedKeys.keys =
              if builtins.isList authorizedKeys
              then authorizedKeys
              else [authorizedKeys];

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

            sdImage.compressImage = true;

            image.fileName = "${hostname}-sd_image-aarch64.img";

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
