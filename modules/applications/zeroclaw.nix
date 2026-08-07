# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: zeroclaw (Renombrado como CLI 'glados')
# =========================================================
{
  flake.applicationModules.zeroclaw = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.services.zeroclaw;
  in {
    options.my.services.zeroclaw = {
      enable = mkEnableOption "Habilitar servicio y CLI GLaDOS (Zeroclaw)";

      cpuThreads = mkOption {
        type = types.str;
        default = "4";
        description = "Número de hilos de CPU asignados.";
      };
    };

    config = mkIf cfg.enable {
      my.apps."zeroclaw".enable = true;
    };
  };
}
