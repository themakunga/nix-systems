# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Tiling window manager module for macOS using AeroSpace.
# AeroSpace manages subsequent startups via start-at-login in aerospace.toml.
{
  flake.darwinModules.tiling = {
    config,
    lib,
    pkgs,
    ...
  }: let
    user = config.system.primaryUser;
    userHome = "/Users/${user}";
  in {
    options.my.services.tiling.enable = lib.mkEnableOption "Tiling window manager";
    config = lib.mkIf config.my.services.tiling.enable {
      my.dotfiles = {
        enable = true;
        packages = [
          {
            name = "aerospace";
          }
        ];
      };
      environment.systemPackages = [pkgs.aerospace];

      system.activationScripts.postActivation.text = lib.mkAfter ''
        # Remove the path created by the old nested Stow target.
        [ -L "${userHome}/.config/aerospace/.config" ] && rm -f "${userHome}/.config/aerospace/.config"

        if ! pgrep -xq AeroSpace; then
          sudo -H -u ${user} /usr/bin/open -a AeroSpace
        fi
      '';
    };
  };
}
