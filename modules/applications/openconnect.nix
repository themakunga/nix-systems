{inputs, ...}: {
  flake.applicationModules.openconnect = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    inherit (pkgs.stdenv.hostPlatform) system;

    cfg = config.my.openconnect;
  in {
    options.my.openconnect = {
      enable = mkEnableOption "OpenConnect and GlobalProtect clients";
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [
        inputs.globalprotect-openconnect.package.${system}.default
        pkgs.openconnect
      ];
    };
  };
}
