# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# === DOCUMENTATION ===
# File: weather.nix
# Path: ./modules/applications/weather.nix
# Description: Módulo para visualizar el clima en la terminal (wthrr)
# =====================
{
  flake.commonModules.weather = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.weather;

    weatherScript = pkgs.writeShellScriptBin "weather" ''
      #!/usr/bin/env bash
      if [ "$#" -eq 0 ]; then
        ${pkgs.wthrr}/bin/wthrr "${cfg.location}" -u "${cfg.units}"
      else
        ${pkgs.wthrr}/bin/wthrr "$@" -u "${cfg.units}"
      fi
    '';
  in {
    options.my.weather = {
      enable = mkEnableOption "Habilitar visor de clima en terminal (wthrr)";

      location = mkOption {
        type = types.str;
        default = "Santiago, Chile";
        description = "Ciudad, comuna o ubicación por defecto para el reporte del clima.";
      };

      units = mkOption {
        type = types.enum ["c" "f"];
        default = "c";
        description = "Sistema de unidades: 'c' para Celsius, 'f' para Fahrenheit.";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [
        weatherScript
        pkgs.wthrr
      ];
    };
  };
}
