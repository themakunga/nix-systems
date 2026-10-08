# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) mkAppModule;
  secretsFile = "${inputs.secrets.outPath}/common.yaml";
in {
  flake.applicationModules.beeptui = mkAppModule "beeptui" "TUI for Beeper" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [
        (pkgs.callPackage "${self}/packages/beeptui/package.nix" {})
      ];
      casks = ["beeper"];
    };
    sysConfig = {config, ...}: let
      user = config.system.primaryUser or "nicolas";
    in {
      sops.secrets."applications/beeper/token" = {
        sopsFile = secretsFile;
        owner = user;
        mode = "0400";
      };
      environment.interactiveShellInit = ''
        export BEEPER_ACCESS_TOKEN="$(cat ${config.sops.secrets."applications/beeper/token".path} 2>/dev/null)"
      '';
    };
  };
}
