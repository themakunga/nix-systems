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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/TheMakunga/.secrets?ref=main";
      flake = false;
    };

    dotfiles = {
      url = "git+ssh://git@github.com/TheMakunga/public-dotfiles?ref=main";
      flake = false;
    };
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
      sops-nix,
      secrets,
      dotfiles,
      ...
    }@inputs:

    let
      system_x86_64 = "x86_64-linux";
      system_aarch64_linux = "aarch64-linux";
      system_aarch64_darwin = "aarch64-darwin";

      customLib = import ./lib { inherit inputs; };

      inherit (customLib) mkNixOS mkDarwin mkSDImage;
    in
    {
      nixosConfigurations = {
        agent = mkNixOS system_aarch64_linux [
          ./hosts/linux/agent
        ];
        pihole = mkNixOS system_aarch64_linux [
          ./hosts/linux/pihole
        ];
        lab-42devs = mkNixOS system_x86_64 [
          ./hosts/linux/lab-42devs
        ];
        mediacenter = mkNixOS system_x86_64 [
          ./hosts/linux/mediacenter
        ];
        steamdeck = mkNixOS system_x86_64 [
          ./hosts/linux/steamdeck
        ];
      };

      packages = {
        agent-image = mkSDImage system_aarch64_linux "agent"
          ./hosts/linux/agent/default.nix;
        pihole-image = mkSDImage system_aarch64_linux "pihole"
          ./hosts/linux/pihole/default.nix;
      };

      darwinConfigurations = {
        kanagawa = mkDarwin system_aarch64_darwin [
          ./hosts/darwin/kanagawa
        ];
        outer-heaven = mkDarwin system_aarch64_darwin [
          ./hosts/darwin/thoughtworks
        ];
      };

      devShell = {

        ${system_aarch64_darwin}.default = import ./shells/dev {
          pkgs = nixpkgs.legacyPackages.${system_aarch64_darwin};
        };

        ${system_aarch64_linux}.default = import ./shells/term {
          pkgs = nixpkgs.legacyPackages.${system_aarch64_linux};
        };
      };

    };
}
