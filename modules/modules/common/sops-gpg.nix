# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# File: sops-gpg.nix Description: Importador declarativo de llaves GPG con sops.
# =========================================================
{
  flake.commonModules.sops-gpg = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf concatMapStringsSep;
    cfg = config.programs.sops.gpg;

    # Extraemos al usuario principal usando Nix, no Bash.
    user = config.system.primaryUser or "nicolas";
  in {
    options.programs.sops.gpg = {
      enable = mkEnableOption "Declarative GPG key importer";
      keys = mkOption {
        default = [];
        type = types.listOf (
          types.submodule {
            options = {
              name = mkOption {type = types.str;};
              publicKey = mkOption {type = types.str;};
              privateKey = mkOption {type = types.str;};
            };
          }
        );
      };
    };

    config = mkIf cfg.enable {
      system.activationScripts =
        if pkgs.stdenv.isDarwin
        then {
          postActivation.text =
            concatMapStringsSep "\n" (key: ''
              if [ -f "${key.publicKey}" ]; then
                sudo -H -u ${user} ${pkgs.gnupg}/bin/gpg --import "${key.publicKey}" 2>/dev/null || true
              fi
              if [ -f "${key.privateKey}" ]; then
                sudo -H -u ${user} ${pkgs.gnupg}/bin/gpg --import "${key.privateKey}" 2>/dev/null || true
              fi
            '')
            cfg.keys;
        }
        else {
          importSopsGpg = {
            text =
              concatMapStringsSep "\n" (key: ''
                if [ -f "${key.publicKey}" ]; then
                  sudo -H -u ${user} ${pkgs.gnupg}/bin/gpg --import "${key.publicKey}" 2>/dev/null || true
                fi
                if [ -f "${key.privateKey}" ]; then
                  sudo -H -u ${user} ${pkgs.gnupg}/bin/gpg --import "${key.privateKey}" 2>/dev/null || true
                fi
              '')
              cfg.keys;
          };
        };
    };
  };
}
