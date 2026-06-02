{
  self,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (self) darwinModules HomeManagerModules commonModules;
in {
  flake.profileModules.thoughtworks = {
    system = {pkgs, ...}: let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in {
      imports = [
        darwinModules.containers-rancher
      ];
    };
    darwin = {
      homebrew.casks = [
        "1password"
        "1password-cli"
      ];
    };
  };
}
