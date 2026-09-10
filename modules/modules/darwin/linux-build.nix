# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: darwinModules.linux-builder
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
        ephemeral = true; # Destruye y recrea la VM limpia en cada reinicio
        maxJobs = 8; # Compilaciones paralelas (era 4 — M4 Max tiene cores de sobra)

        config = {
          virtualisation = {
            memorySize = mkForce 12288; # 12 GB de RAM (era 8GB)
            cores = mkForce 8; # 8 Cores de CPU (era 4 — M4 Max tiene 14 performance cores)
            diskSize = mkForce 51200; # 50 GB de disco virtual
          };
          # ponytail: clock drift fix — restart launchd service to re-sync VM clock.
          # services.timesyncd cannot be set here: CI builds aarch64 VM on x86_64,
          # any VM-level NixOS change produces uncacheable aarch64 derivations.
        };
      };

      # Da permisos al constructor para inyectar binarios en tu Mac
      nix.settings.trusted-users = ["@admin"];
    };
  };
}
