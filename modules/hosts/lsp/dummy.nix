{
  self,
  inputs,
  ...
}: let
  inherit
    (self)
    nixpkgs
    home-manager
    sops-nix
    darwin
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
    nixosConfigurations.lsp-dummy = nixpkgs.lib.nixosModules {
      specialArgs = {
        inherit self inputs;
        homeName = "lsp-dummy-nixos";
      };

      modules = [
        commonModules.settings
        commonModules.arch.nixos.x64
        sops-nix.nixosModules.sops
        home-manager.nixosModule.home-manager

        commonModules.userProfiles
        commonModules.authoruizedKeys
        commonModules.network
        commonModules.home-manager
        nixosModules.base-machine

        userModules.admin
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
    darwinConfigurations.lsp-dummy = darwin.lib.darwinSystem {
      specialArgs = {
        inherit self inputs;
        hostName = "lsp-dummy-darwin";
      };

      modules = [
        commonModules.settings
        commonModules.arch.darwin.silicon
        home-manager.darwinModules.home-manager
        commonModules.userProfiles
        commonModules.home-manager
        userModules.admin
      ];
    };
  };
}
