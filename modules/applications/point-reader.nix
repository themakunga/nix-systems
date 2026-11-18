# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.point-reader = self.lib.mkAppModule "point-reader" "Read selection or pointed block on macOS" {
    meta = {
      pkgs,
      lib,
      ...
    }: {
      level = "system";
      packages = lib.optionals pkgs.stdenv.isDarwin [
        (pkgs.callPackage ../../packages/point-reader/package.nix {})
      ];
    };
    sysConfig = {
      pkgs,
      lib,
      ...
    }:
      lib.mkIf pkgs.stdenv.isDarwin {
        launchd.user.agents.point-reader.serviceConfig = {
          ProgramArguments = [
            "${pkgs.callPackage ../../packages/point-reader/package.nix {}}/Applications/Point Reader.app/Contents/MacOS/point-reader"
          ];
          RunAtLoad = true;
          ProcessType = "Interactive";
        };
      };
  };
}
