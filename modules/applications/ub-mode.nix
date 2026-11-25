# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.ub-mode = self.lib.mkAppModule "ub-mode" "ub-mode skill and companion tools" {
    meta = {pkgs, ...}: let
      tools = pkgs.callPackage ../../packages/ub-mode/package.nix {};
    in {
      level = "system";
      packages = with tools; [crapper dryer mutator uml-viewer];
    };
    sysConfig = {
      config,
      pkgs,
      lib,
      ...
    }: let
      tools = pkgs.callPackage ../../packages/ub-mode/package.nix {};
      targets =
        [
          {
            user = config.my.dotfiles.user;
            home = config.my.dotfiles.home;
          }
        ]
        ++ config.my.dotfiles.additionalUsers;
      seed = target: let
        commands = ''
          set -eu
          for runtime in .agents .claude .hermes .gemini; do
            mkdir -p "${target.home}/$runtime/skills"
            destination="${target.home}/$runtime/skills/ub-mode"
            if [ ! -e "$destination" ] && [ ! -L "$destination" ]; then
              ln -s ${tools.skill} "$destination"
            fi
          done
        '';
      in ''
        /run/wrappers/bin/sudo -H -u ${lib.escapeShellArg target.user} ${pkgs.runtimeShell} -c ${lib.escapeShellArg commands}
      '';
    in {
      system.activationScripts.seedUbMode = {
        deps = ["users" "seedCodingAgents"];
        text = lib.concatMapStringsSep "\n" seed targets;
      };
    };
  };
}
