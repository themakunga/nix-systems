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
{self, ...}: {
  flake.nixosModules.nix-anywhere = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mapAttrsToList;
    cfg = config.my.nix-anywhere;

    # public_keys.json vive en el mismo repo (nix-systems), no en secrets
    # ya que son claves públicas y no necesitan cifrado SOPS
    keysFile = "${self}/public_keys.json";
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

      # Solo inyectar las SSH keys — no redefinir isNormalUser ni
      # extraGroups, ya que el usuario puede estar definido por
      # un userProfile con configuración distinta (e.g., servidor).
      users.users.${targetUser}.openssh.authorizedKeys.keys = allKeys;
    };
  };
}
