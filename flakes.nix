{
  description = "Flake build rpi installers and multi host systems";

  nicConfig = {
    extra-subtitutions = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    connect-timeout = 5;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      nixpkgs-unstablem,
      nix-darwin,
      nix-homebrew,
      mac-app-util,
      home-manager,
      nixos-hardware,
      ...
    }@inputs:

    let

      lib = import ./lib { inherit inputs; };
    in
    {
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
    };
}
