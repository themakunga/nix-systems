# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: tailscale.nix
# Path: ./modules/applications/tailscale.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.tailscale = {
    core = mkAppModule "tailscale-core" "Tailscale Core Daemon and CLI" ({
      config,
      lib,
      options,
      ...
    }: let
      inherit (lib) mkForce optionalAttrs;
      isLinux = options ? system.nixos;
      isDarwin = options ? system.darwin;
    in
      {
        my.apps."tailscale-core" = {
          level = "system";
          apps = ["tailscale"];
        };

        sops.secrets."tailscale/auth_token" = {};
      }
      // optionalAttrs isDarwin {
        services.tailscale.enable = mkForce false;
      }
      // optionalAttrs isLinux {
        services.tailscale = {
          enable = true;
          authKeyFile = config.sops.secrets."tailscale/auth_token".path;
        };

        networking.firewall = {
          trustedInterfaces = ["tailscale0"];
          allowedUDPPorts = [config.services.tailscale.port];
          checkReversePath = "loose";
        };
      });

    gui = mkAppModule "tailscale-gui" "Tailscale GUI App" ({
      lib,
      options,
      ...
    }: let
      inherit (lib) optionals;
      isLinux = options ? system.nixos;
    in {
      my.apps."tailscale-gui" = {
        level = "system";
        apps = optionals isLinux ["trayscale"];
      };
    });
  };
}
