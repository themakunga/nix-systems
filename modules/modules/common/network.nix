# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: network.nix
# Path: ./modules/modules/common/network.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.commonModules.network = {
    lib,
    pkgs,
    hostName ? "nixos-default",
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    inherit (lib) optionalAttrs;
  in {
    networking =
      {
        inherit hostName;
      }
      // optionalAttrs isDarwin {
        computerName = hostName;

        localHostName = hostName;
      };
  };
}
