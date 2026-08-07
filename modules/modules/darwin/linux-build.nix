# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: linux-builder.nix
# Path: ./modules/modules/darwin/linux-builder.nix
# Description: Constructor remoto aarch64-linux para macOS
# =====================
{
  flake.darwinModules.linux-builder = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.linux-builder;
  in {
    options.my.linux-builder = {
      enable = mkEnableOption "Linux builder (VM) para compilar NixOS nativamente desde macOS";
    };

    config = mkIf cfg.enable {
      nix.linux-builder = {
        enable = true;
        ephemeral = true; # Limpia la VM al reiniciar
        maxJobs = 4;
        config.virtualisation = {
          memorySize = 8192; # 8 GB de RAM dedicados a compilar Linux
          cores = 4;
        };
      };

      # Confía en el builder para que actúe como sustituto local de binarios
      nix.settings.trusted-users = ["@admin"];
    };
  };
}
