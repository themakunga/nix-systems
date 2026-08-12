# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
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
    inherit (lib) mkEnableOption mkOption types mkIf concatStringsSep;
    cfg = config.my.weather;

    # Construcción dinámica de los argumentos según la configuración de Nix
    forecastArg =
      if builtins.length cfg.forecast > 0
      then "-f " + (concatStringsSep "," cfg.forecast)
      else "";

    # Wrapper interactivo con soporte para modo monitoreo
    weatherScript = pkgs.writeShellScriptBin "weather" ''
      #!/usr/bin/env bash

      WATCH_MODE=0
      INTERVAL=300 # 5 minutos (5 * 60 segundos)

      # Detectamos si el usuario pasó la bandera de monitoreo
      if [ "$1" = "--watch" ] || [ "$1" = "-w" ]; then
        WATCH_MODE=1
        shift # Eliminamos la bandera de los argumentos para no confundir a wthrr
      fi

      # Función central que inyecta todos los argumentos de forma dinámica
      run_weather() {
        if [ "$#" -eq 0 ]; then
          ${pkgs.wthrr}/bin/wthrr "${cfg.location}" -u "${cfg.units}" ${forecastArg}
        else
          ${pkgs.wthrr}/bin/wthrr "$@" -u "${cfg.units}" ${forecastArg}
        fi
      }

      # Lógica de ejecución
      if [ "$WATCH_MODE" -eq 1 ]; then
        # Modo Bucle: Limpia la pantalla, muestra el clima y espera
        while true; do
          clear
          run_weather "$@"
          echo ""
          echo "⏳ Actualizando cada 5 minutos... (Presiona Ctrl+C para salir)"
          sleep $INTERVAL
        done
      else
        # Modo Normal: Una sola ejecución
        run_weather "$@"
      fi
    '';
  in {
    options.my.weather = {
      enable = mkEnableOption "Habilitar visor de clima en terminal (wthrr)";

      location = mkOption {
        type = types.str;
        default = "Peñalolén";
        description = "Ciudad, comuna o ubicación por defecto para el reporte del clima.";
      };

      units = mkOption {
        type = types.enum ["c" "f"];
        default = "c";
        description = "Sistema de unidades: 'c' para Celsius, 'f' para Fahrenheit.";
      };

      forecast = mkOption {
        type = types.listOf (types.enum ["d" "w" "day" "week"]);
        default = ["d" "w"];
        description = "Elementos del pronóstico a mostrar ('d' para detallado de hoy, 'w' para resumen de la semana).";
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
