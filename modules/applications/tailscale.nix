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
    core =
      mkAppModule "tailscale" "Enable tailscale
    module" ({
        config,
        lib,
        pkgs,
        ...
      }: let
        inherit (lib) mkIf mkForce;
        inherit (pkgs.stdenv.hostPlaform) isLinux isDarwin;
      in {
        my.apps.tailscale = {
          level = "system";
          apps = [
            "tailscale"
          ];
        };

        sops.secrets."tailscale/auth_token" = {};

        services.tailscale = mkIf isLinux {
          enable = true;
          authKeyFile = config.sops.secrets."tailscale/auth_token".path;
        };

        networking.firewall = mkIf isLinux {
          trustedInterfaces = ["tailscale0"];
          allowedUDPPorts = [config.services.tailscale.port];
          checkReversePath = "loose";
        };

        service.tailscale.enable = mkIf isDarwin (mkForce false);
      });
    gui =
      mkAppModule "tailscale-gui" "Enable GUI in Tailscale, only in linux"
      ({
        pkgs,
        lib,
        ...
      }: let
        inherit (lib) optionals;
        inherit (pkgs.stdenv.hostPlaform) isLinux;
      in {
        my.apps."tailscale-gui" = {
          level = "system";
          apps = optionals isLinux ["trayscale"];
        };
      });
  };
}
