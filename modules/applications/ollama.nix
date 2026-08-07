# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: ollama (Motor de Modelos LLM)
# =========================================================
{
  flake.applicationModules.ollama = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.services.ollama;
  in {
    options.my.services.ollama = {
      enable = mkEnableOption "Habilitar servicio de Ollama";

      maxVramBytes = mkOption {
        type = types.str;
        default = "8589934592";
        description = "Límite máximo de VRAM en bytes.";
      };

      parallelRequests = mkOption {
        type = types.str;
        default = "1";
        description = "Número de peticiones paralelas de inferencia.";
      };
    };

    config = mkIf cfg.enable {
      my.apps."ollama".enable = true;
    };
  };
}
