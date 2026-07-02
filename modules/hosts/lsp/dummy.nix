{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    home-manager
    sops-nix
    nix-darwin
    ;
  inherit
    (self)
    commonModules
    darwinModules
    nixosModules
    userModules
    ;
in {
  flake = {
    nixosConfigurations.lsp-dummy = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit self inputs;
        hostName = "lsp-dummy-nixos";
      };

      modules = [
        commonModules.settings
        commonModules.arch.nixos.x64
        sops-nix.nixosModules.sops
        commonModules.host-secrets
        home-manager.nixosModules.home-manager

        commonModules.userProfiles
        commonModules.authorizedKeys
        commonModules.network
        commonModules.home-manager
        nixosModules.base-machine

        userModules.nicolas-admin
        {
          my.base-machine = {
            enable = true;
            bootMode = "uefi";
          };
          fileSystems."/".device = "/dev/null";
          boot.loader.grub.device = ["/dev/null"];
        }
      ];
    };
    darwinConfigurations.lsp-dummy = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit self inputs;
        hostName = "lsp-dummy-darwin";
      };

      modules = [
        darwinModules.common
        commonModules.settings
        sops-nix.darwinModules.sops
        commonModules.host-secrets
        commonModules.arch.darwin.silicon
        home-manager.darwinModules.home-manager
        commonModules.userProfiles
        commonModules.home-manager
        userModules.nicolas-personal
      ];
    };
  };
}
