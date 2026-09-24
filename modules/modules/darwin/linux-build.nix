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
        ephemeral = false; # Conserva la VM y su Nix store entre reinicios
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
      nix.settings = {
        trusted-users = ["@admin"];
        # builders-use-substitutes: el builder VM descarga sustitutos directamente
        # en lugar de recibirlos del daemon Darwin — necesario para ARM64 builds.
        builders-use-substitutes = true;
        extra-substituters = [
          "https://nixos-hardware.cachix.org"
          "https://themakunga.cachix.org"
        ];
        extra-trusted-public-keys = [
          # Clave verificada en https://nixos-hardware.cachix.org
          "nixos-hardware.cachix.org-1:OqV48MwUzN0rmApeP5Dp/4hQv+8Uz7x1qPtd+6BaLgc="
          # Clave verificada en https://app.cachix.org/cache/themakunga (flake.nix)
          "themakunga.cachix.org-1:6G4uSeEclXBILBnmlbDsTAapL2vE0ndx4laL02AzzR0="
        ];
      };
    };
  };
}
