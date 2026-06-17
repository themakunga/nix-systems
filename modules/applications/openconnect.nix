{inputs, ...}: {
  flake.homeManagerModules.openconnect = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.programs.openconnect;
    inherit (pkgs.stdenv.hostPlatform) system;
  in {
    options.programs.openconnect = {
      enable = lib.mkEnableOption "GlobalProtect OpenConnect VPN Client";
    };

    config = lib.mkdIf cfg.enable {
      home.packages = [
        inputs.globalprotect-openconnect.packages.${system}.default
        pkgs.openconnect
      ];
    };
  };
}
