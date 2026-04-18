{ config, pkgs, inputs, system, ... }:
{
  nixpkgs.overlays = [
    (import ./feedr.nix { inherit inputs system; })

    (import ./unstable.nix {inherit inputs system; })
  ];
}
