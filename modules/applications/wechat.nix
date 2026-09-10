# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# WeChat — copies plain config from secrets/shared-conf/wechat/ via activation script.
# macOS: installed via cask. Linux x86_64: wechat-uos. aarch64: config only.
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.wechat = mkAppModule "wechat" "Enable WeChat" {
    meta = {
      pkgs,
      lib,
      ...
    }: {
      level = "system";
      casks = lib.optionals pkgs.stdenv.isDarwin ["wechat"];
      packages = lib.optionals (pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64) [pkgs.wechat-uos];
    };

    sysConfig = {
      inputs,
      pkgs,
      ...
    }: let
      isDarwin = pkgs.stdenv.isDarwin;
      user = "nicolas";
      userHome =
        if isDarwin
        then "/Users/${user}"
        else "/home/${user}";
      destDir =
        if isDarwin
        then "${userHome}/Library/Application Support/WeChat"
        else "${userHome}/.config/wechat";
      srcDir = "${inputs.secrets.outPath}/shared-conf/wechat";
      script = ''
        if [ -d "${srcDir}" ]; then
          mkdir -p "${destDir}"
          cp -rf "${srcDir}/." "${destDir}/"
          chown -R ${user} "${destDir}"
          chmod -R u+rw "${destDir}"
        fi
      '';
    in {
      system.activationScripts =
        if isDarwin
        then {postActivation.text = script;}
        else {setupWechatConfig = {text = script;};};
    };
  };
}
