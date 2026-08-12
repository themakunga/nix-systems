# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{
  flake.darwinModules.linux-builder = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkForce;
    cfg = config.my.linux-builder;
  in {
    options.my.linux-builder = {
      enable = mkEnableOption "Linux builder (VM) para compilar NixOS nativamente desde macOS";
    };

    config = mkIf cfg.enable {
      nix.linux-builder = {
        enable = true;
        ephemeral = true;
        maxJobs = 4;

        # Usamos notación plana con mkForce para aplastar el valor por defecto
        config = {
          virtualisation.memorySize = mkForce 8192;
          virtualisation.cores = mkForce 4;
        };
      };

      nix.settings.trusted-users = ["@admin"];
    };
  };
}
