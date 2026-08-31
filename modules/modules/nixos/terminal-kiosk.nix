# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: terminal-kiosk.nix
# Path: ./modules/modules/nixos/terminal-kiosk.nix
# Description: Entorno kiosk Wayland (Cage + Foot) para acceso
#              directo a terminal en pantalla completa. Diseñado
#              para nodos headless con monitor ocasional (RPi5).
# =====================
{lib, ...}: {
  flake.nixosModules.terminal-kiosk = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption mkIf types;
    cfg = config.my.terminal-kiosk;
  in {
    options.my.terminal-kiosk = {
      enable = mkEnableOption "Wayland kiosk con Cage + Foot a pantalla completa";

      user = mkOption {
        type = types.str;
        description = "Usuario que ejecuta la sesión kiosk";
      };

      multiplexer = mkOption {
        type = types.enum ["none" "zellij"];
        default = "zellij";
        description = "Multiplexor de terminal dentro del kiosk";
      };
    };

    config = mkIf cfg.enable {
      # Aceleración gráfica — requerida por Wayland en RPi5
      hardware.graphics.enable = true;

      environment.systemPackages =
        [
          pkgs.cage
          pkgs.foot
        ]
        ++ lib.optionals (cfg.multiplexer == "zellij") [pkgs.zellij];

      # greetd: auto-login directo a la terminal, sin pantalla de login
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = let
            terminal =
              if cfg.multiplexer == "zellij"
              then "${pkgs.zellij}/bin/zellij"
              else "${pkgs.foot}/bin/foot";
          in "${pkgs.cage}/bin/cage -s -- ${pkgs.foot}/bin/foot ${terminal}";
          inherit (cfg) user;
        };
      };

      # True Color en la terminal
      environment.variables = {
        COLORTERM = "truecolor";
        TERM = "xterm-256color";
      };

      # Boot más limpio — sin spam del kernel en pantalla
      boot.consoleLogLevel = 3;
    };
  };
}
