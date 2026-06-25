{inputs, ...}: {
  flake.applicationModules.openconnect = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    environment.systemPackages = [
      inputs.globalprotect-openconnect.packages.${system}.default
      pkgs.openconnect
    ];
  };
}
