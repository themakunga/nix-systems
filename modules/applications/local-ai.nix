# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: local-ai (Ollama + Zeroclaw)
# =========================================================
{lib, ...}: {
  flake.applicationModules.local-ai = {config, ...}: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.services.local-ai;
  in {
    options.my.services.local-ai = {
      enable = mkEnableOption "Habilitar entorno de IA local";

      cpuThreads = mkOption {
        type = types.str;
        default = "4";
        description = "Número de P-Cores de CPU a utilizar.";
      };

      maxVramBytes = mkOption {
        type = types.str;
        default = "8589934592";
        description = "Límite máximo de VRAM en bytes.";
      };

      parallelRequests = mkOption {
        type = types.str;
        default = "1";
        description = "Peticiones dinámicas en paralelo.";
      };
    };

    config = mkIf cfg.enable {
      my.apps."local-ai".enable = true;
    };
  };
}
