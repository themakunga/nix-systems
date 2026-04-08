{
  description = "Flake build rpi installers and multi host systems";

  nicConfig = {
    extra-subtitutions = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    connect-timeout = 5;
  };

  imputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    argononed = {
      url = "github:nvmd/argononed";
      flake = false;
    };

    flake-compat.url = "github:edolstra/flake-compat";

    nixos-images = {
      url = "github:nvmd/nixos-images/sdimage-installer";
      inputs.nixos-stable.follows = "nixpkgs";
      inputs.nixos-unstable.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };
  };

  outputs = {self, nixpkgs, nixpkgs-unstablem, argononed, nixos-images, darwin,
    nix-homebrew, mac-app-util, ...}@inputs:

    let

    lib = import ./lib/default.nix {
      inherit (nixpkgs) lib;
      inputs = inputs // { inherit self; };
    };


}
