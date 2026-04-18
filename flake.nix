{
  description = "Flake build rpi installers and multi host systems";

  nixConfig = {
    extra-substitutions = [ "https://themakunga.cachix.org" ];
    extra-trusted-public-keys = [
      "themakunga.cachix.org-1:6G4uSeEclXBILBnmlbDsTAapL2vE0ndx4laL02AzzR0="
    ];
    connect-timeout = 5;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      nix-homebrew,
      mac-app-util,
      home-manager,
      nixos-hardware,
      ...
    }@inputs:

    let

      lib = import ./lib { inherit inputs; };

      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      ## development environments
      devShell = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = ./modules/shell.nix { inherit pkgs; };
        }
      );
      # nixOS/Linux base configurations
      nixosConfigurations = {
        rpi5 = lib.mkNixosSystem {
          system = "aarch64-linux";
          hostname = "rpi-lab";
          username = "personal";
          extraModules = [
            nixos-hardware.nixosModules.raspberry-pi-5
            "${nixpkgs}/nixos/modules/install/sd-card/sd-image-aarch64.nix"
          ];
        };
        rpi02 = lib.mkNixosSystem {
          system = "aarch64-linux";
          hostname = "pihole";
          username = "generic-admin";
          extraModules = [
            nixos-hardware.nixosModules.rasperry-pi-zero-2
            "${nixpkgs}/nixos/modules/install/sd-card/sd-image-aarch64.nix"
          ];
        };

      };
      ## darwin (osx) configurations
      darwinConfigurations = {
        personal = lib.mkDarwinSystem {
          system = "aarch64-darwin";
          hostname = "kanagawa";
          username = "personal";
        };
        thoughtworoks = lib.mkDarwinSystem {
          system = "aarch64-darwin";
          hostname = "outer-heaven";
          username = "thoughtworks";
        };
      };
      ## SD image builders
      packages.aarch64-linux = {
        image-rpi5 = lib.mkSdImage self.nixosConfigurations.rpi5;
        image-rpi02 = lib.mkSdImage self.nixosConfigurations.rpi02;
      };
    };
}
