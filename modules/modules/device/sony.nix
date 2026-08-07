# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: deviceModules.sony
# =========================================================
{
  flake.deviceModules.sony = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkMerge;
    cfg = config.my.devices.sony;
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  in {
    options.my.devices.sony = {
      enable = mkEnableOption "Habilitar utilidades y ecualización para audífonos Sony";
    };

    config = mkIf cfg.enable (mkMerge [
      (mkIf isDarwin {
        homebrew.casks = [
          "eqmac"
        ];
        environment.systemPackages = with pkgs; [
          switchaudio-osx
        ];
      })

      (mkIf (!isDarwin) {
        environment.systemPackages = with pkgs; [
          pavucontrol
        ];
      })
    ]);
  };
}
