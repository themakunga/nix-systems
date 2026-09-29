# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# WeeChat — terminal IRC client.
# Config (irc.conf + weechat.conf) copied from secrets/shared-conf/weechat/ at activation.
{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) mkAppModule;
  secretsPath = inputs.secrets.outPath;
in {
  flake.applicationModules.weechat = mkAppModule "weechat" "Enable WeeChat IRC client" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.weechat];
    };

    sysConfig = {
      pkgs,
      lib,
      ...
    }: let
      user = "nicolas";
      userHome =
        if pkgs.stdenv.isDarwin
        then "/Users/${user}"
        else "/home/${user}";
      destDir = "${userHome}/.config/weechat";
      srcDir = "${secretsPath}/shared-conf/weechat";
      script = lib.stringAfter ["users"] ''
        if [ -d "${srcDir}" ]; then
          mkdir -p "${destDir}/themes"
          cp -f "${srcDir}/irc.conf" "${destDir}/irc.conf"
          cp -f "${srcDir}/weechat.conf" "${destDir}/weechat.conf"
          cp -f "${srcDir}/themes/nesthib-tokyonight.theme" "${destDir}/themes/nesthib-tokyonight.theme"
          chown -R ${user} "${destDir}"
          chmod 600 "${destDir}/irc.conf"
          chmod 600 "${destDir}/weechat.conf"
        fi
      '';
    in {
      system.activationScripts.weechat-config = script;
    };
  };
}
