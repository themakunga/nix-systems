# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: wifi.nix
# Path: ./modules/modules/nixos/wifi.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{inputs, ...}: {
  flake.nixosModules.wifi = {config, ...}: {
    sops = {
      secrets = {
        "wifi/AMANDA" = {
          sopsFile = "${inputs.secrets}/common.yaml";
        };
        "wifi/42DEVS" = {
          sopsFile = "${inputs.secrets}/common.yaml";
        };
        "wifi/42DEVS_5G" = {
          sopsFile = "${inputs.secrets}/common.yaml";
        };
      };
      templates."wireless.env".content = ''
        AMANDA_PSK=${config.sops.placeholder."wifi/AMANDA"}
        42DEVS_PSK=${config.sops.placeholder."wifi/42DEVS"}
        42DEVS_5G_PSK=${config.sops.placeholder."wifi/42DEVS_5G"}
      '';
    };

    networking.wireless = {
      enable = true;

      secretsFile = config.sops.templates."wireless.env".path;

      networks = {
        "AMANDA" = {
          pskRaw = "ext:AMANDA_PSK";
          priority = 10;
        };
        "42Devs" = {
          pskRaw = "ext:42DEVS";
          priority = 5;
        };
        "Nicolas`s iPhone" = {
          pskRaw = "ext:42DEVS_5G";
          priority = 1;
        };
      };
    };
  };
}
