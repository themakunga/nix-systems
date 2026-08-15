# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# File: host-secrets.nix
# Description: Configuración global de secretos SOPS a nivel de Host.
# =========================================================
{
  flake.commonModules.host-secrets = {
    lib,
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types mkDefault mapAttrs;
    cfg = config.my.hostSecrets;
    user = config.system.primaryUser or "nicolas";
    userHome =
      if pkgs.stdenv.isDarwin
      then "/Users/${user}"
      else "/home/${user}";
  in {
    options.my.hostSecrets = {
      file = mkOption {
        type = types.str;
      };
      userSecrets = mkOption {
        type = types.attrsOf types.attrs;
        default = {};
      };
    };

    config = {
      sops = {
        defaultSopsFile = mkDefault cfg.file;
        validateSopsFiles = false;

        # 🛑 APAGAR GPG A NIVEL DE SISTEMA
        # Esto evita que SOPS intente crear /var/root/.gnupg en macOS
        gnupg.sshKeyPaths = [];

        age.sshKeyPaths = [
          "/etc/ssh/ssh_host_ed25519_key"
          "${userHome}/.ssh/id_ed25519"
        ];
        secrets = mapAttrs (_name: value:
          value
          // {
            owner = mkDefault user;
          })
        cfg.userSecrets;
      };
    };
  };
}
