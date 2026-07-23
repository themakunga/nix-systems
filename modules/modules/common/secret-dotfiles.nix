# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
_: {
  flake.commonModules.secret-dotfiles = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.secretDotfiles;
    user = config.system.primaryUser or "nicolas";
    userHome =
      if pkgs.stdenv.isDarwin
      then "/Users/${user}"
      else "/home/${user}";
  in {
    options.my.secretDotfiles = {
      enable = mkEnableOption "Enable mapping of secret dotfiles from shared-conf";
    };

    config = mkIf cfg.enable {
      my.sharedSecrets = {
        "aws" = {
          path = "${userHome}/.aws";
          mode = "0600";
        };
        "dott" = {
          path = "${userHome}/.config/dott";
          mode = "0600";
        };
        "feedr" = {
          path = "${userHome}/.config/feedr";
          mode = "0600";
        };
        "halloy" = {
          path = "${userHome}/.config/halloy";
          mode = "0600";
        };
        "irssi" = {
          path = "${userHome}/.irssi";
          mode = "0600";
        };
        "lazysql" = {
          path = "${userHome}/.config/lazysql";
          mode = "0600";
        };
        "matterhorn" = {
          path = "${userHome}/.config/matterhorn";
          mode = "0600";
        };
        "nchat" = {
          path = "${userHome}/.config/nchat";
          mode = "0600";
        };
        "posting" = {
          path = "${userHome}/.config/posting";
          mode = "0600";
        };
        "ssh" = {
          path = "${userHome}/.ssh";
          mode = "0600";
        };
      };
    };
  };
}
