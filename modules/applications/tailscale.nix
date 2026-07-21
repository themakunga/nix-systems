# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.tailscale = {
    core = mkAppModule "tailscale-core" "Tailscale Core Daemon and CLI" {
      meta = {pkgs, ...}: {
        level = "system";
        packages = [pkgs.tailscale];
      };
      sysConfig = {
        config,
        lib,
        options,
        ...
      }: let
        inherit (lib) mkForce optionalAttrs mkMerge mkIf;
        isLinux = options ? system.nixos;
        isDarwin = options ? system.darwin;
      in
        mkMerge [
          {
            sops.secrets."tailscale/auth_token" = {};
            services.tailscale.enable = mkIf isDarwin (mkForce false);
          }
          (optionalAttrs isLinux {
            services.tailscale = {
              enable = true;
              authKeyFile = config.sops.secrets."tailscale/auth_token".path;
            };
            networking.firewall = {
              trustedInterfaces = ["tailscale0"];
              allowedUDPPorts = [config.services.tailscale.port];
              checkReversePath = "loose";
            };
          })
        ];
    };

    gui = mkAppModule "tailscale-gui" "Tailscale GUI App" {
      meta = {
        pkgs,
        lib,
        options,
        ...
      }: let
        isLinux = options ? system.nixos;
        isDarwin = options ? system.darwin;
      in {
        level = "system";
        packages = lib.optionals isLinux [pkgs.trayscale];
        masApps = lib.optionalAttrs isDarwin {"tailscale" = 1475387142;};
      };
      sysConfig = {};
    };
  };
}
