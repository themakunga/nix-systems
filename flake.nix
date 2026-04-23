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
      url = "git+ssh://git.github.com/TheMakunga/.secrets";
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
        agent = mkNixOS system_aarch64_linux [ ./hosts/linux/agent.nix ];
        pihole = mkNixOS system_aarch64_linux [ ./hosts/linux/pihole.nix ];
        lab-42devs = mkNixOS system_x86_64 [ ./hosts/linux/lab-42devs.nix ];
        mediacenter = mkNixOS system_x86_64 [ ./hosts/linux/mediacenter.nix ];
        steamdeck = mkNixOS system_x86_64 [ ./hosts/linux/steamdeck.nix ];
      };

      packages = {
        agent-image = mkSDImage system_aarch64_linux "agent" ./hosts/linux/agent.nix;
        pihole-image = mkSDImage system_aarch64_linux "pihole" ./hosts/linux/pihole.abort.nix;
      };

      darwinConfigurations = {
        kanagawa = mkDarwin system_aarch64_darwin [ ./hosts/darwin/kanagawa.nix ];
        outer-heaven = mkDarwin system_aarch64_darwin [
          ./hosts/darwin/thoughtworks.nix
        ];
      };

      devShell = {

        ${system_aarch64_darwin}.default = import ./devShell {
          pkgs = nixpkgs.legacyPackages.${system_aarch64_darwin};
        };

        ${system_aarch64_linux}.default = import ./devShell {
          pkgs = nixpkgs.legacyPackages.${system_aarch64_linux};
        };
      };

    };
}
