# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# WeChat — plain config from secrets/shared-conf/wechat/ → platform config dir.
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

    sysConfig = {pkgs, ...}: let
      user = "nicolas";
      userHome =
        if pkgs.stdenv.isDarwin
        then "/Users/${user}"
        else "/home/${user}";
      confDir =
        if pkgs.stdenv.isDarwin
        then "${userHome}/Library/Application Support/WeChat"
        else "${userHome}/.config/wechat";
    in {
      my.sharedPlain.wechat = {
        source = "wechat";
        path = confDir;
        owner = user;
        mode = "0700";
      };
    };
  };
}
