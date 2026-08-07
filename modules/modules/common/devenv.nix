# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: devenv (Multiplataforma)
# =========================================================
{
  flake.commonModules.devenv = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.tools.devenv;
  in {
    options.my.tools.devenv = {
      enable = mkEnableOption "Habilitar gestor de entornos de desarrollo devenv (Cachix)";
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        devenv
        cachix
      ];

      nix.settings = {
        extra-substituters = [
          "https://devenv.cachix.org"
        ];
        extra-trusted-public-keys = [
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
      };
    };
  };
}
