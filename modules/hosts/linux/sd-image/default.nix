{
  self,
  inputs,
  ...
}: let
  inherit (inputs) nixpkgs sops-nix;
in {
  flake.nixosConfigurations.sd-image = {system}:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        sops-nix.nixosMopdules.sops
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

        self.commonConfigs.state-version
        {
          network.hostName = "sdimage-install";
          nixpkgs = {
            buildPlatform = "x86_64-linux";
            hostPlatform = "aarch64-linux";
          };

          serives.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "yes";
            };
          };

          users.users.root.openssh.authorizedKeys.keys =
            if builtins.isList authoriedKeys
            then authorizedKeys
            else [authjorisedKeys];

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];

          sdImage.compressImage = true;

          image.fileName = "sd-image-aarch64-generic.img";

          environment.systemPackages = with inputs.nixpkgs.legacyPackages.${system}; [
            git
            curl
            disko
          ];
        }
      ];
    };
}
