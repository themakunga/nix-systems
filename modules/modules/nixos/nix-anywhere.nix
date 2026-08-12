# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: nix-anywhere.nix
# Path: ./modules/modules/nixos/nix-anywhere.nix
# Description: Módulo base para el despliegue desatendido con nix-anywhere
# =====================
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.nix-anywhere = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mapAttrsToList;
    cfg = config.my.nix-anywhere;

    # ⚠️ NIX NO LEE YAML NATIVAMENTE, CAMBIADO A JSON
    # Asegúrate de tener este archivo como JSON en tu repositorio de secretos
    keysFile = "${inputs.secrets}/public_keys.json";
    templateFile = "${self}/template/hardware-configuration.nix";

    publicKeysData =
      if builtins.pathExists keysFile
      then builtins.fromJSON (builtins.readFile keysFile)
      else {};

    sshKeysAttr = publicKeysData.ssh or {};
    allKeys = mapAttrsToList (_: v: v.public_key) sshKeysAttr;

    targetUser = config.my.primaryUser.username or "nicolas";
  in {
    options.my.nix-anywhere = {
      enable = mkEnableOption "Habilitar soporte base para instalación con nix-anywhere";
    };

    imports = lib.optional (builtins.pathExists templateFile) templateFile;

    config = mkIf cfg.enable {
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "prohibit-password";
      };

      users.users.root.openssh.authorizedKeys.keys = allKeys;

      users.users.${targetUser} = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager"];
        openssh.authorizedKeys.keys = allKeys;
      };
    };
  };
}
