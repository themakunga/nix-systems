# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# WeeChat: public UI, connections shared with Halloy's private configuration.
{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.weechat = mkAppModule "weechat" "Enable WeeChat IRC client" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.weechat];
    };
    sysConfig = {
      config,
      pkgs,
      lib,
      ...
    }: let
      user = config.system.primaryUser or "nicolas";
      userHome =
        if pkgs.stdenv.isDarwin
        then "/Users/${user}"
        else "/home/${user}";
      dotfiles = "${userHome}/.public-dotfiles/weechat";
      destDir = "${userHome}/.config/weechat";
      script = ''
        if [ -f "${dotfiles}/sync-halloy.py" ]; then
          SECRETS_DIR="${inputs.secrets.outPath}" \
          WEECHAT_HOME="${destDir}" \
          PYTHON="${pkgs.python3}/bin/python3" \
            ${pkgs.bash}/bin/bash "${dotfiles}/deploy.sh"
          chown -R ${user} "${destDir}"
        else
          echo "WeeChat: public-dotfiles/weechat is missing; configuration not deployed" >&2
        fi
      '';
    in {
      system.activationScripts =
        if pkgs.stdenv.isDarwin
        then {postActivation.text = lib.mkAfter script;}
        else {weechat-config = lib.stringAfter ["users" "stowDotfiles"] script;};
    };
  };
}
