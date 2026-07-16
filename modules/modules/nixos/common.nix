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
      };
    };
  };
}
