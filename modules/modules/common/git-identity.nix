# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# File: git-identity.nix
# Description: Gestor de múltiples identidades Git y firmas por directorio.
#
# Modos de workspace (opción projectRoot):
#   null   → configs en ~/.gitconfig.workspaces/<name>   (modo clásico)
#   "path" → configs en <path>/<name>/.gitconfig         (modo per-project)
#            + <path>/<name>/.ssh/config
#
# Tipos aceptados:
#   privateKey → PATH a la llave (~/… o /run/secrets/…) — NUNCA contenido
#   keyId      → fingerprint literal O ruta a archivo con fingerprint
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
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    userHome =
      if isDarwin
      then "/Users/${user}"
      else "/home/${user}";

    # Expande ~ al home del usuario (Nix eval-time, no runtime)
    resolveTilde = s: builtins.replaceStrings ["~/"] ["${userHome}/"] s;

    # Genera bash que resuelve keyId en $_key_id.
    # La decisión se toma en Nix eval-time para evitar SC2193:
    #   path absoluto ("/run/secrets/...") → lee el archivo en runtime
    #   fingerprint literal                → asigna directo
    resolveKeyIdSh = val:
      if lib.hasPrefix "/" val
      then ''_key_id=$(cat "${val}" 2>/dev/null || true)''
      else ''_key_id="${val}"'';

    # Bloque [user]+[gpg]+[commit] para un keyId dado
    gpgBlockSh = keyId: dest: ''
      ${resolveKeyIdSh keyId}
      if [ -n "$_key_id" ]; then
        printf '[user]\n  signingkey = %s\n[gpg]\n  format = openpgp\n[commit]\n  gpgsign = true\n' \
          "$_key_id" >> "${dest}"
      fi
    '';

    # Bloque [core] sshCommand usando ruta directa al key
    sshBlockSh = keyPath: dest: ''
      printf '[core]\n  sshCommand = ssh -i %s -o IdentitiesOnly=yes -o AddKeysToAgent=yes -o UseKeychain=yes\n' \
        "${resolveTilde keyPath}" >> "${dest}"
    '';

    # Ruta del projectRoot expandida (Nix eval-time)
    projRoot =
      if cfg.projectRoot != null
      then resolveTilde cfg.projectRoot
      else null;
  in {
    options.programs.git-identity = {
      enable = mkEnableOption "Gestor de identidad de Git parametrizado";

      projectRoot = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "~/Projects";
        description = ''
          Cuando está definido, cada workspace escribe su configuración en
          <projectRoot>/<name>/.gitconfig  y  <projectRoot>/<name>/.ssh/config
          en lugar de ~/.gitconfig.workspaces/<name>.
          El nombre del workspace debe coincidir con el nombre del directorio
          de primer nivel bajo projectRoot.
        '';
      };

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
          enable = mkEnableOption "Firmado GPG global";
          keyId = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Fingerprint GPG literal o ruta a archivo con el fingerprint.";
          };
        };
        ssh = {
          enable = mkEnableOption "Auth SSH global";
          privateKey = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "PATH a la llave privada (~/… o /run/secrets/…).";
          };
        };
      };

      workspaces = mkOption {
        default = {};
        description = "Identidades Git por directorio de trabajo.";
        type = types.attrsOf (types.submodule {
          options = {
            directory = mkOption {type = types.str;};
            realName = mkOption {type = types.str;};
            email = mkOption {type = types.str;};
            gpg = {
              enable = mkEnableOption "Firmado GPG para este workspace";
              keyId = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Fingerprint GPG literal o ruta a archivo con el fingerprint.";
              };
            };
            ssh = {
              enable = mkEnableOption "Auth SSH para este workspace";
              privateKey = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "PATH a la llave privada (~/… o /run/secrets/…).";
              };
            };
          };
        });
      };
    };

    config = mkIf cfg.enable {
      system.activationScripts = let
        scriptContent = ''
          GIT_NIX_CONF="${userHome}/.gitconfig.nix-managed"
          WORKSPACES_DIR="${userHome}/.gitconfig.workspaces"

          mkdir -p "$WORKSPACES_DIR"

          # ── Cabecera del config global gestionado por Nix ──────────────
          cat > "$GIT_NIX_CONF" << 'NIXEOF'
          # Archivo autogenerado por Nix. NO EDITAR DIRECTAMENTE.
          [pull]
            rebase = false
          NIXEOF

          # ── Identidad global (default para repos sin match específico) ──
          ${optionalString cfg.global.enable ''
            printf '[user]\n  name = %s\n  email = %s\n' \
              "${cfg.global.realName}" "${cfg.global.email}" >> "$GIT_NIX_CONF"

            ${optionalString (cfg.global.gpg.enable && cfg.global.gpg.keyId != null)
              (gpgBlockSh cfg.global.gpg.keyId "$GIT_NIX_CONF")}

            ${optionalString (cfg.global.ssh.enable && cfg.global.ssh.privateKey != null)
              (sshBlockSh cfg.global.ssh.privateKey "$GIT_NIX_CONF")}
          ''}

          # ── Workspaces ─────────────────────────────────────────────────
          ${concatStringsSep "\n" (mapAttrsToList (name: ws:
            if projRoot != null
            then let
              wsDir = "${projRoot}/${name}";
              wsGit = "${wsDir}/.gitconfig";
              wsSsh = "${wsDir}/.ssh/config";
            in ''
              # [workspace: ${name}] → ${wsDir}/
              mkdir -p "${wsDir}/.ssh"

              printf '[user]\n  name = %s\n  email = %s\n' \
                "${ws.realName}" "${ws.email}" > "${wsGit}"

              ${optionalString (ws.gpg.enable && ws.gpg.keyId != null)
                (gpgBlockSh ws.gpg.keyId wsGit)}

              ${optionalString (ws.ssh.enable && ws.ssh.privateKey != null) ''
                # .ssh/config con la llave específica de este cliente
                cat > "${wsSsh}" << 'SSHEOF'
                Host *
                  IdentityFile ${resolveTilde ws.ssh.privateKey}
                  AddKeysToAgent yes
                  UseKeychain yes
                  StrictHostKeyChecking accept-new
                SSHEOF
                printf '[core]\n  sshCommand = ssh -F %s\n' "${wsSsh}" >> "${wsGit}"
              ''}

              printf '[includeIf "gitdir/i:%s/**"]\n  path = %s\n' \
                "${wsDir}" "${wsGit}" >> "$GIT_NIX_CONF"

              chown -R ${user} "${wsDir}" 2>/dev/null || true
            ''
            else ''
              # [workspace: ${name}] → ~/.gitconfig.workspaces/ (modo clásico)
              printf '[user]\n  name = %s\n  email = %s\n' \
                "${ws.realName}" "${ws.email}" > "$WORKSPACES_DIR/${name}"

              ${optionalString (ws.gpg.enable && ws.gpg.keyId != null)
                (gpgBlockSh ws.gpg.keyId "$WORKSPACES_DIR/${name}")}

              ${optionalString (ws.ssh.enable && ws.ssh.privateKey != null)
                (sshBlockSh ws.ssh.privateKey "$WORKSPACES_DIR/${name}")}

              printf '[includeIf "gitdir/i:%s/"]\n  path = .gitconfig.workspaces/%s\n' \
                "${ws.directory}" "${name}" >> "$GIT_NIX_CONF"
            '')
          cfg.workspaces)}

          chown ${user} "$GIT_NIX_CONF"
          chown -R ${user} "$WORKSPACES_DIR"

          # ── Asegurar que ~/.gitconfig incluye el config gestionado ─────
          # (puede ser un symlink de Stow — no duplicar el include)
          touch "${userHome}/.gitconfig"
          if ! ${pkgs.git}/bin/git config --file "${userHome}/.gitconfig" --get-all include.path |
            grep -Fxq -e "$GIT_NIX_CONF" -e "$HOME/.gitconfig.nix-managed"; then
            printf '\n[include]\n  path = %s\n' "$GIT_NIX_CONF" >> "${userHome}/.gitconfig"
          fi
          chown ${user} "${userHome}/.gitconfig"
        '';
      in
        if isDarwin
        then {postActivation.text = scriptContent;}
        else {gitIdentitySetup.text = scriptContent;};
    };
  };
}
