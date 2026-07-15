# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: settings.nix
# Path: ./modules/modules/common/settings.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  globals,
  self,
  ...
}: let
  inherit (self) overlays;
in {
  flake.commonModules.settings = {
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
    inherit (lib) mkIf optionals mkMerge;
    inherit (globals.stateVersion) darwin nixos;
  in {
    system.stateVersion = mkMerge [
      (mkIf isLinux nixos)
      (mkIf isDarwin darwin)
    ];
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users =
          [
            "root"
            "nicolas"
          ]
          ++ optionals isLinux ["@wheel"]
          ++ optionals isDarwin ["@admin"];
      };
    };
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
      overlays = [
        overlays.unstable
      ];
    };
  };
}
