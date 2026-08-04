# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# File: git-identity.nix
# Description: Gestor avanzado de múltiples identidades Git y firmas.
# =========================================================
{
  flake.commonModules.git-identity = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optionalString concatStringsSep mapAttrsToList;
    cfg = config.programs.git-identity;

    user = config.system.primaryUser or "nicolas";
    userHome =
      if pkgs.stdenv.isDarwin
      then "/Users/${user}"
      else "/home/${user}";
  in {
    options.programs.git-identity = {
      enable = mkEnableOption "Gestor de identidad de Git parametrizado";
      global = {
        enable = mkEnableOption "Identidad global por defecto";
        realName = mkOption {
          type = types.str;
          default = "";
        };
        email = mkOption {
          type = types.str;
          default = "";
        };
        gpg = {
          enable = mkEnableOption "Firmado global con GPG";
          keyId = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
        ssh = {
          enable = mkEnableOption "Auth SSH global";
          privateKey = mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
      };
      workspaces = mkOption {
        default = {};
        type = types.attrsOf (
          types.submodule {
            options = {
              directory = mkOption {type = types.str;};
              realName = mkOption {type = types.str;};
              email = mkOption {type = types.str;};
              gpg = {
                enable = mkEnableOption "Firmado GPG para este workspace";
                keyId = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
              };
              ssh = {
                enable = mkEnableOption "Auth SSH para este workspace";
                privateKey = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
              };
            };
          }
        );
      };
    };

    config = mkIf cfg.enable {
      system.activationScripts = let
        scriptContent = ''
          GIT_NIX_CONF="${userHome}/.gitconfig.nix-managed"
          WORKSPACES_DIR="${userHome}/.gitconfig.workspaces"

          mkdir -p "$WORKSPACES_DIR"

          cat << 'EOF' > "$GIT_NIX_CONF"
          # Archivo autogenerado por Nix. NO EDITAR DIRECTAMENTE.
          EOF

          ${optionalString cfg.global.enable ''
              cat << 'EOF' >> "$GIT_NIX_CONF"
            [user]
              name = ${cfg.global.realName}
              email = ${cfg.global.email}
            EOF
              ${optionalString cfg.global.gpg.enable ''
                  GPG_KEY_ID=$(cat ${cfg.global.gpg.keyId} 2>/dev/null || echo "")
                  if [ -n "$GPG_KEY_ID" ]; then
                    cat << EOF >> "$GIT_NIX_CONF"
                signingkey = $GPG_KEY_ID
              [commit]
                gpgsign = true
              EOF
                  fi
            ''}
              ${optionalString cfg.global.ssh.enable ''
                  cat << EOF >> "$GIT_NIX_CONF"
              [core]
                sshCommand = ssh -i ${cfg.global.ssh.privateKey} -o IdentitiesOnly=yes
              EOF
            ''}
          ''}

          ${concatStringsSep "\n" (mapAttrsToList (name: ws: ''
                # MAGIA: gitdir/i: hace que la ruta sea insensible a mayúsculas/minúsculas
                cat << 'EOF' >> "$GIT_NIX_CONF"
              [includeIf "gitdir/i:${ws.directory}/"]
                path = $WORKSPACES_DIR/${name}
              EOF

                cat << 'EOF' > "$WORKSPACES_DIR/${name}"
              [user]
                name = ${ws.realName}
                email = ${ws.email}
              EOF

                ${optionalString ws.gpg.enable ''
                    GPG_KEY_ID=$(cat ${ws.gpg.keyId} 2>/dev/null || echo "")
                    if [ -n "$GPG_KEY_ID" ]; then
                      cat << EOF >> "$WORKSPACES_DIR/${name}"
                  signingkey = $GPG_KEY_ID
                [commit]
                  gpgsign = true
                EOF
                    fi
              ''}

                ${optionalString ws.ssh.enable ''
                    cat << EOF >> "$WORKSPACES_DIR/${name}"
                [core]
                  sshCommand = ssh -i ${ws.ssh.privateKey} -o IdentitiesOnly=yes
                EOF
              ''}
            '')
            cfg.workspaces)}

          chown ${user} "$GIT_NIX_CONF"
          chown -R ${user} "$WORKSPACES_DIR"

          # MAGIA 2: Escribimos directo en ~/.gitconfig (que NO está manejado por Stow)
          # Esto evita bloqueos de 'git config' y salta la limitación de macOS con /etc/gitconfig
          touch "${userHome}/.gitconfig"
          if ! grep -q "path = $GIT_NIX_CONF" "${userHome}/.gitconfig"; then
            cat << EOF >> "${userHome}/.gitconfig"

          [include]
            path = $GIT_NIX_CONF
          EOF
          fi
          chown ${user} "${userHome}/.gitconfig"
        '';
      in
        if pkgs.stdenv.isDarwin
        then {postActivation.text = scriptContent;}
        else {gitIdentitySetup.text = scriptContent;};
    };
  };
}
