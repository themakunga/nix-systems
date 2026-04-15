{ config, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      feedr = prev.callPackage ../../packages/feedr { };
    })
  ];
}
