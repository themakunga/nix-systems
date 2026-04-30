{ inputs, ... }:
let
  inherit (inputs) pkgs;
in
{
  flake.nixosModules.userNicolas = { pkgs, ... }: { };
}
