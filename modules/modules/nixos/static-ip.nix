# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: static-ip.nix
# Path: ./modules/modules/nixos/static-ip.nix
# Description: Implementación de IP estática para NixOS.
#              Las opciones se declaran en commonModules.network.
#
# Uso en un host:
#   nixosModules = [ "static-ip" ... ];
#
#   my.network.staticIP = {
#     enable    = true;
#     address   = "192.168.5.85";   # IP deseada
#     gateway   = "192.168.5.1";    # Gateway del router
#     interface = "end0";           # ip link show para encontrarla
#     # prefixLength = 24;          # opcional, default /24
#     # dns = ["1.1.1.1" "9.9.9.9"]; # opcional
#   };
# =====================
{lib, ...}: {
  flake.nixosModules.static-ip = {config, ...}: let
    inherit (lib) mkIf;
    cfg = config.my.network.staticIP;
  in {
    config = mkIf cfg.enable {
      networking = {
        # Deshabilitar DHCP global — la IP la asignamos nosotros
        useDHCP = false;

        # IP estática en la interfaz especificada
        interfaces.${cfg.interface} = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = cfg.address;
              prefixLength = cfg.prefixLength;
            }
          ];
        };

        # Gateway y DNS
        defaultGateway = cfg.gateway;
        nameservers = cfg.dns;
      };
    };
  };
}
