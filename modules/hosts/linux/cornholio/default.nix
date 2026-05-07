{ self, inputs, ... }:
let
  inherit (inputs)
    nixpkgs
    nixos-hardware
    disko
    sops-nix
    secrets
    dotfiles
    ;
  inherit (self)
    nixosModules
    commonModules
    diskModules
    ;
in
{
  flake = {
    nixosConfigurations.cornholio = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit secrets dotfiles; };
      modules = [
        commonModules.nix-settings
        commonModules.state-version

        disko.nixosModules.disko
        diskModules.cornholio

        sops-nix.nixosModules.sops

        {
          boot.loader.grub.enable = true;

          services.openssh.enable = true;

          zramSwap.enable = true;
        }

      ];
    };
    builderModules.cornholio = nixosModules.bootstrap {
      system = "aarch64-linux";
      hardware = nixos-hardware.nixosModules.raspberry-pi-5;
      hostname = "cornholio";
      authorizedKeys = [ ];
      extraModules = [ ];
    };
  };
}
