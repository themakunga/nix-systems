# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: darwinModules.linux-builder
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
        ephemeral = true; # Destruye y recrea la VM limpia en cada reinicio
        maxJobs = 4;

        # Usamos notación plana con mkForce para aplastar los valores por defecto
        config = {
          virtualisation = {
            memorySize = mkForce 8192; # 8 GB de RAM
            cores = mkForce 4; # 4 Cores de CPU
            diskSize = mkForce 51200; # 50 GB de disco virtual
          };
        };
      };

      # Da permisos al constructor para inyectar binarios en tu Mac
      nix.settings.trusted-users = ["@admin"];
    };
  };
}
