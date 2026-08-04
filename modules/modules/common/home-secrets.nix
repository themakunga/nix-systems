# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# File: home-secrets.nix
# Description: Configuración de secretos a nivel de usuario.
# =========================================================
{inputs, ...}: let
  inherit (inputs) secrets;
in {
  flake.commonModules.home-secrets = {
    config,
    pkgs,
    ...
  }: let
    user = config.system.primaryUser or "nicolas";
    userHome =
      if pkgs.stdenv.isDarwin
      then "/Users/${user}"
      else "/home/${user}";

    # CORRECCIÓN: La propiedad DEBE llamarse "sopsFile"
    sopsConfig = {sopsFile = "${secrets}/common.yaml";};
  in {
    sops = {
      age = {
        sshKeyPaths = ["${userHome}/.ssh/id_ed25519"];
        generateKey = false;
      };

      gnupg.sshKeyPaths = [];

      secrets = {
        "wifi/AMANDA" = sopsConfig;
        "wifi/42DEVS_5G" = sopsConfig;
        "wifi/42DEVS" = sopsConfig;
      };
    };
  };
}
