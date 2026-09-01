# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: ollama.nix
# Path: ./modules/applications/ollama.nix
# Description: Servidor LLM local vía Ollama.
#              Diseñado para RPi5 (CPU-only, sin GPU).
#              Expone la API REST en :11434 (Tailscale + red local).
# =====================
{
  flake.applicationModules.ollama = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption mkIf types;
    cfg = config.my.ollama;
  in {
    options.my.ollama = {
      enable = mkEnableOption "Servidor LLM local con Ollama";

      host = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "Dirección de escucha de la API REST. 0.0.0.0 = red local + Tailscale.";
      };

      port = mkOption {
        type = types.port;
        default = 11434;
        description = "Puerto de la API REST de Ollama.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Abrir el puerto en el firewall de NixOS.";
      };
    };

    config = mkIf cfg.enable {
      services.ollama = {
        enable = true;
        host = cfg.host;
        port = cfg.port;
        # RPi5 no tiene GPU dedicada — CPU only.
        # acceleration = null es el valor por defecto en NixOS.
      };

      # CLI disponible en el sistema
      environment.systemPackages = [pkgs.ollama];

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [cfg.port];
      };
    };
  };
}
