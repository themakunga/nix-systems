# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.deviceModules.logitech = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.devices.logitech;
  in {
    options.my.devices.logitech = {
      enable = mkEnableOption "Habilitar gestión de hardware Logitech";
    };

    config = mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
      homebrew = {
        casks = [
          "openlogi"
        ];
      };
    };
  };
}
