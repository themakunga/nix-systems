# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: common.nix
# Path: ./modules/modules/nixos/common.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{inputs, ...}: {
  flake = {
    nixosModules = {
      common = {
        imports = [
          inputs.self.commonModules.nixos-secrets
        ];

        networking.networkmanager.enable = true;

        time.timeZone = "America/Santiago";
        i18n.defaultLocale = "en_US.UTF-8";

        # Gestión automática de espacio en el Nix store
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 14d";
        };
        nix.settings = {
          auto-optimise-store = true; # deduplicar store con hardlinks tras cada build
          min-free = 5368709120; # 5 GB — lanzar GC si hay menos espacio libre
          max-free = 10737418240; # 10 GB — liberar hasta 10 GB en cada GC automático
        };
      };
    };
  };
}
