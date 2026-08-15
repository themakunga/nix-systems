# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: deviceModules.hyperx
# =========================================================
{
  flake.deviceModules.hyperx = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkMerge;
    cfg = config.my.devices.hyperx;
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  in {
    options.my.devices.hyperx = {
      enable = mkEnableOption "Habilitar suite de gestión y cancelación de ruido para micrófono HyperX";
    };

    config = mkIf cfg.enable (mkMerge [
      (mkIf isDarwin {
        homebrew.casks = [
        ];
      })

      (mkIf (!isDarwin) {
        environment.systemPackages = with pkgs; [
          noisetorch
          rnnoise-plugin
        ];
      })
    ]);
  };
}
