# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: network.nix
# Path: ./modules/modules/common/network.nix
# Description: Módulo de red — hostname + IP estática para Darwin y NixOS.
#
# Darwin : la implementación usa system.activationScripts (networksetup).
# NixOS  : añadir "static-ip" a nixosModules del host; este módulo declara
#           las opciones que ese módulo consume.
#
# Uso en un host Darwin:
#   my.network.staticIP = {
#     enable    = true;
#     address   = "192.168.1.10";
#     gateway   = "192.168.1.1";
#     interface = "Ethernet";   # networksetup -listallnetworkservices
#   };
#
# Uso en un host NixOS (también añadir "static-ip" a nixosModules):
#   my.network.staticIP = {
#     enable    = true;
#     address   = "192.168.1.20";
#     gateway   = "192.168.1.1";
#     interface = "end0";       # ip link show
#   };
# =====================
{
  flake.commonModules.network = {
    lib,
    pkgs,
    config,
    hostName ? "nixos-default",
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    inherit (lib) mkEnableOption mkOption mkIf mkMerge types optionalAttrs;
    cfg = config.my.network.staticIP;

    # Convierte prefijo → máscara decimal punteada (evaluado en Nix, no en shell)
    # Ejemplo: prefixToMask 24 = "255.255.255.0"
    pow2 = n:
      if n == 0
      then 1
      else 2 * pow2 (n - 1);
    prefixToMask = p: let
      invMask = pow2 (32 - p) - 1;
      m = 4294967295 - invMask;
      b1 = m / 16777216;
      r1 = m - b1 * 16777216;
      b2 = r1 / 65536;
      r2 = r1 - b2 * 65536;
      b3 = r2 / 256;
      b4 = r2 - b3 * 256;
    in "${toString b1}.${toString b2}.${toString b3}.${toString b4}";
  in {
    # ── Opciones (compatibles Darwin + NixOS) ────────────────────────────────
    options.my.network = {
      staticIP = {
        enable = mkEnableOption "IP estática declarativa para este host";

        address = mkOption {
          type = types.str;
          description = "Dirección IPv4 (ej. 192.168.1.10)";
          example = "192.168.1.10";
          default = "";
        };

        prefixLength = mkOption {
          type = types.int;
          default = 24;
          description = "Longitud del prefijo (/24 = 255.255.255.0)";
        };

        gateway = mkOption {
          type = types.str;
          description = "Gateway por defecto (ej. 192.168.1.1)";
          example = "192.168.1.1";
          default = "";
        };

        interface = mkOption {
          type = types.str;
          description = ''
            NixOS : nombre de interfaz kernel (end0, enp3s0, eth0, wlan0…)
                    Detectar: ip link show
            Darwin: nombre del servicio de red (Ethernet, Wi-Fi…)
                    Detectar: networksetup -listallnetworkservices
          '';
          example = "end0";
          default = "";
        };

        dns = mkOption {
          type = types.listOf types.str;
          default = ["1.1.1.1" "9.9.9.9"];
          description = "Servidores DNS";
        };

        extraInterfaces = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Darwin: interfaces adicionales donde aplicar la misma IP.
            Útil cuando el equipo se conecta tanto por Ethernet como por Wi-Fi.
            Detectar: networksetup -listallnetworkservices
            Ejemplo: [ "Wi-Fi" ] (si interface = "Ethernet")
          '';
          example = ["Wi-Fi"];
        };
      };
    };

    config = mkMerge [
      # ── Hostname (Darwin + NixOS) ─────────────────────────────────────────
      {
        networking =
          {inherit hostName;}
          // optionalAttrs isDarwin {
            computerName = hostName;
            localHostName = hostName;
          };
      }

      # ── IP estática Darwin — networksetup (activation script) ─────────────
      # Se aplica a interface + extraInterfaces. La máscara y los comandos se
      # generan en Nix en tiempo de evaluación; no requiere loops en shell.
      # NixOS: implementado en nixosModules.static-ip (networking.interfaces).
      (mkIf (cfg.enable && isDarwin) {
        system.activationScripts.staticNetwork.text = let
          mask = prefixToMask cfg.prefixLength;
          dnsStr = lib.concatStringsSep " " cfg.dns;
          allIfaces = [cfg.interface] ++ cfg.extraInterfaces;
          applyIface = iface: ''
            echo "  → ${iface}"
            /usr/sbin/networksetup -setmanual "${iface}" \
              "${cfg.address}" "${mask}" "${cfg.gateway}" 2>&1 || true
            /usr/sbin/networksetup -setdnsservers "${iface}" \
              ${dnsStr} 2>&1 || true
          '';
        in ''
          echo "=> IP estática: ${cfg.address}/${toString cfg.prefixLength} gw ${cfg.gateway}"
          ${lib.concatMapStrings applyIface allIfaces}
        '';
      })
    ];
  };
}
