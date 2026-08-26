# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: workspace-identity
# Archivo: modules/modules/common/workspace-identity.nix
#
# Declara identidades Git completas por directorio de trabajo.
# Para cada workspace declarado el módulo hace automáticamente:
#
#   1. Registra en sops.secrets las llaves SSH y GPG del profile
#   2. Configura programs.git-identity.workspaces (gitconfig por dir)
#   3. Importa las llaves GPG al keyring vía programs.sops.gpg
#   4. (Opcional) Sincroniza la llave SSH pública a GitHub / GitLab
#      cuando detecta que la llave cambió (hash SHA-256 del pub key)
#
# ── ARCHIVOS ENCRIPTADOS CON SOPS ─────────────────────────────────────
#
# Los secrets deben existir PREVIAMENTE en un archivo YAML encriptado
# con sops. Por defecto se usa el archivo del host (my.hostSecrets.file).
# Para usar un archivo distinto, especifica la opción `sopsFile`.
#
# Estructura esperada dentro del YAML encriptado:
#
#   profiles:
#     <profileName>:
#       ssh:
#         private_key: |
#           -----BEGIN OPENSSH PRIVATE KEY-----
#           ...
#       gpg:
#         private_key: |  (bloque armor GPG)
#           ...
#         public_key: |
#           ...
#         key_id: "FINGERPRINT_O_ID_CORTO"
#     # Si usas sync a plataformas, agrega también:
#     workspaces:
#       <nombre>:
#         github_token: "ghp_..."     # scope: write:public_key
#         gitlab_token: "glpat-..."   # scope: api
#
# Para encriptar / editar:
#   sops edit secrets/hosts/<hostname>.yaml
#
# ── RUTAS SOPS GENERADAS ──────────────────────────────────────────────
#
#   profiles/<profileName>/ssh/private_key
#   profiles/<profileName>/gpg/private_key
#   profiles/<profileName>/gpg/public_key
#   profiles/<profileName>/gpg/key_id
#   <platforms.github.tokenSecretPath>   ← si github.enable = true
#   <platforms.gitlab.tokenSecretPath>   ← si gitlab.enable = true
#
# ── USO MÍNIMO ────────────────────────────────────────────────────────
#
#   my.workspaceIdentities.latam = {
#     directory   = "~/Projects/latam/**";
#     profileName = "latam";
#     realName    = "Nicolas Villarroel";
#     email       = "nicolas@latam.com";
#     # sopsFile = null → usa my.hostSecrets.file (el .yaml del host)
#   };
#
# ── CON ARCHIVO SOPS PROPIO Y SYNC A PLATAFORMAS ─────────────────────
#
#   my.workspaceIdentities.personal = {
#     directory   = "~/Projects/personal/**";
#     profileName = "personal";
#     realName    = "Nicolas Villarroel";
#     email       = "me@example.com";
#     sopsFile    = "${inputs.secrets}/hosts/kanagawa.yaml";
#     platforms.github = {
#       enable          = true;
#       tokenSecretPath = "workspaces/personal/github_token";
#     };
#   };
#
# ── MIGRACIÓN ─────────────────────────────────────────────────────────
#
# Una vez declarado aquí, elimina del profile correspondiente:
#   programs.git-identity.workspaces.<nombre>
#   sops.secrets."profiles/<profileName>/..."
#   programs.sops.gpg.keys  (los de este workspace)
# =========================================================
{
  flake.commonModules.workspace-identity = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit
      (lib)
      mkOption
      types
      mkIf
      filterAttrs
      mapAttrs
      mapAttrsToList
      concatStringsSep
      optionalString
      optionalAttrs
      ;

    user = config.system.primaryUser or "nicolas";
    hostName = config.networking.hostName or "nix";

    # Solo workspaces con enable = true
    wsCfg = config.my.workspaceIdentities;
    activeWs = filterAttrs (ws: ws.enable) wsCfg;

    # ── Resuelve los atributos sops de un secret ───────────────────────
    # Si sopsFile es null usa el defaultSopsFile del host (my.hostSecrets.file).
    # Si es un path, lo pasa explícitamente a sops-nix.
    secretAttrs = ws: extraAttrs:
      extraAttrs
      // (optionalAttrs (ws.sopsFile != null) {sopsFile = ws.sopsFile;});

    # ── Binarios referenciados en el script de activación ──────────────
    curl = "${pkgs.curl}/bin/curl";
    jq = "${pkgs.jq}/bin/jq";
    sshKeygen = "${pkgs.openssh}/bin/ssh-keygen";
    sha256sum = "${pkgs.coreutils}/bin/sha256sum";

    # ── Script de sync para una plataforma concreta ────────────────────
    #
    #   name        — nombre del workspace (ej. "latam")
    #   ws          — attrset de opciones del workspace
    #   platName    — "github" | "gitlab"
    #   platCfg     — ws.platforms.github o ws.platforms.gitlab
    #   apiBase     — URL base de la API REST
    #
    # El script solo corre si el archivo de la llave privada existe
    # (sops lo decripta durante la activación, antes de postActivation).
    # Si no existe (primer boot o secret no configurado) se salta
    # silenciosamente para no romper la activación.
    #
    mkSyncScript = name: ws: platName: platCfg: apiBase: let
      privKeyFile = config.sops.secrets."profiles/${ws.profileName}/ssh/private_key".path;
      tokenFile = config.sops.secrets.${platCfg.tokenSecretPath}.path;
      stateDir = "/var/lib/git-identity";
      stateFile = "${stateDir}/${name}-${platName}.fingerprint";
      keyTitle = "nix-managed-${name}@${hostName}";
      keysEndpoint = "${apiBase}/user/keys";

      authHeader =
        if platName == "github"
        then ''-H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json"''
        else ''-H "PRIVATE-TOKEN: $TOKEN"'';
    in ''
      # ── workspace-identity: ${name} → ${platName} ──────────────────
      # Los archivos son descifrados por sops-nix antes de este script.
      # Si no existen todavía (secret no configurado en el YAML), se omite.
      if [ -f "${privKeyFile}" ] && [ -f "${tokenFile}" ]; then
        _PUB=$(${sshKeygen} -y -f "${privKeyFile}" 2>/dev/null || true)
        if [ -n "$_PUB" ]; then
          _FP=$(printf '%s' "$_PUB" | ${sha256sum} | cut -d' ' -f1)
          _LAST_FP=$(cat "${stateFile}" 2>/dev/null || true)

          if [ "$_FP" != "$_LAST_FP" ]; then
            _TOKEN=$(cat "${tokenFile}" 2>/dev/null || true)
            if [ -n "$_TOKEN" ]; then
              echo "🔑 workspace-identity [${name}/${platName}]: llave SSH cambió, sincronizando..."

              # Eliminar llaves anteriores gestionadas por Nix (mismo título)
              _OLD_IDS=$(${curl} -sf --max-time 15 \
                ${authHeader} \
                "${keysEndpoint}" 2>/dev/null \
                | ${jq} -r '.[] | select(.title == "${keyTitle}") | .id' 2>/dev/null \
                || true)

              for _KID in $_OLD_IDS; do
                ${curl} -sf -X DELETE --max-time 15 \
                  ${authHeader} \
                  "${keysEndpoint}/$_KID" >/dev/null 2>&1 || true
              done

              # Subir la nueva llave pública
              _RESP=$(${curl} -sf -X POST --max-time 15 \
                ${authHeader} \
                -H "Content-Type: application/json" \
                "${keysEndpoint}" \
                -d "{\"title\":\"${keyTitle}\",\"key\":\"$_PUB\"}" 2>/dev/null || true)

              if printf '%s' "$_RESP" | ${jq} -e '.id' >/dev/null 2>&1; then
                echo "✅ workspace-identity [${name}/${platName}]: llave SSH sincronizada"
                mkdir -p "${stateDir}"
                printf '%s' "$_FP" > "${stateFile}"
              else
                echo "⚠️  workspace-identity [${name}/${platName}]: error al sincronizar" >&2
                echo "   Verifica que el token tenga los permisos correctos" >&2
              fi
            fi
          fi
        fi
      else
        echo "⚠️  workspace-identity [${name}/${platName}]: secret no disponible, omitiendo sync" \
          "(¿está el secret en el YAML encriptado del host?)" >&2
      fi
    '';

    # Script completo (todos los workspaces activos con plataformas habilitadas)
    fullSyncScript = concatStringsSep "\n" (lib.flatten (
      mapAttrsToList (name: ws: [
        (optionalString
          (ws.platforms.github.enable && ws.platforms.github.tokenSecretPath != "")
          (mkSyncScript name ws "github" ws.platforms.github "https://api.github.com"))

        (optionalString
          (ws.platforms.gitlab.enable && ws.platforms.gitlab.tokenSecretPath != "")
          (mkSyncScript name ws "gitlab" ws.platforms.gitlab
            "https://${ws.platforms.gitlab.host}/api/v4"))
      ])
      activeWs
    ));

    hasPlatformSync =
      builtins.any
      (ws:
        (ws.platforms.github.enable && ws.platforms.github.tokenSecretPath != "")
        || (ws.platforms.gitlab.enable && ws.platforms.gitlab.tokenSecretPath != ""))
      (builtins.attrValues activeWs);
  in {
    # ── Opciones ────────────────────────────────────────────────────────
    options.my.workspaceIdentities = mkOption {
      default = {};
      description = "Identidades Git declarativas por directorio de trabajo.";
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Activar esta identidad de workspace.";
          };

          directory = mkOption {
            type = types.str;
            example = "~/Projects/latam/**";
            description = "Glob del directorio que activa la identidad (gitdir/i).";
          };

          profileName = mkOption {
            type = types.str;
            description = ''
              Nombre del profile en el YAML encriptado con sops.
              Mapea a las rutas:
                profiles/<profileName>/ssh/private_key
                profiles/<profileName>/gpg/{private_key, public_key, key_id}
            '';
          };

          sopsFile = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Ruta al archivo YAML encriptado con sops que contiene
              los secrets SSH y GPG de este workspace.

              null → usa sops.defaultSopsFile (definido por my.hostSecrets.file,
                     que apunta a secrets/hosts/<hostname>.yaml).

              Útil cuando los secrets de este workspace están en un
              archivo distinto al del host, por ejemplo:
                sopsFile = "''${inputs.secrets}/common.yaml";
            '';
          };

          realName = mkOption {
            type = types.str;
            description = "Nombre completo para los commits de Git.";
          };

          email = mkOption {
            type = types.str;
            description = "Email para los commits de Git.";
          };

          secretOwner = mkOption {
            type = types.str;
            default = user;
            description = "Usuario propietario de los secrets descifrados.";
          };

          gpg = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Habilitar firma y verificación GPG para este workspace.";
            };
          };

          ssh = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Habilitar autenticación SSH para este workspace.";
            };
          };

          platforms = {
            github = {
              enable = mkOption {
                type = types.bool;
                default = false;
                description = "Sincronizar la llave SSH pública con GitHub cuando cambie.";
              };
              tokenSecretPath = mkOption {
                type = types.str;
                default = "";
                example = "workspaces/personal/github_token";
                description = ''
                  Ruta dentro del YAML sops del Personal Access Token de GitHub.
                  Scopes necesarios: write:public_key
                '';
              };
            };

            gitlab = {
              enable = mkOption {
                type = types.bool;
                default = false;
                description = "Sincronizar la llave SSH pública con GitLab cuando cambie.";
              };
              host = mkOption {
                type = types.str;
                default = "gitlab.com";
                example = "gitlab.tuempresa.com";
                description = "Host de la instancia GitLab.";
              };
              tokenSecretPath = mkOption {
                type = types.str;
                default = "";
                example = "workspaces/latam/gitlab_token";
                description = ''
                  Ruta dentro del YAML sops del Personal Access Token de GitLab.
                  Scopes necesarios: api  (o read_user + write_repository)
                '';
              };
            };
          };
        };
      });
    };

    # ── Configuración (solo cuando hay al menos un workspace activo) ────
    config = mkIf (activeWs != {}) {
      # 1. Registrar sops.secrets para cada workspace ───────────────────
      #    Si ws.sopsFile != null, sobreescribe el defaultSopsFile del host.
      #    El orden de los secrets en el YAML encriptado debe ser:
      #      profiles/<profileName>/ssh/private_key
      #      profiles/<profileName>/gpg/private_key
      #      profiles/<profileName>/gpg/public_key
      #      profiles/<profileName>/gpg/key_id
      sops.secrets = lib.mkMerge (
        mapAttrsToList (_name: ws:
          {
            "profiles/${ws.profileName}/ssh/private_key" =
              secretAttrs ws {owner = ws.secretOwner;};
            "profiles/${ws.profileName}/gpg/private_key" =
              secretAttrs ws {owner = ws.secretOwner;};
            "profiles/${ws.profileName}/gpg/public_key" =
              secretAttrs ws {owner = ws.secretOwner;};
            "profiles/${ws.profileName}/gpg/key_id" =
              secretAttrs ws {owner = ws.secretOwner;};
          }
          // (optionalAttrs
            (ws.platforms.github.enable && ws.platforms.github.tokenSecretPath != "") {
              "${ws.platforms.github.tokenSecretPath}" =
                secretAttrs ws {owner = ws.secretOwner;};
            })
          // (optionalAttrs
            (ws.platforms.gitlab.enable && ws.platforms.gitlab.tokenSecretPath != "") {
              "${ws.platforms.gitlab.tokenSecretPath}" =
                secretAttrs ws {owner = ws.secretOwner;};
            }))
        activeWs
      );

      # 2. Configurar git-identity por workspace ────────────────────────
      #    Escribe ~/.gitconfig.nix-managed con bloques includeIf por dir.
      #    Los secrets ya están descifrados en /run/secrets/... en este punto.
      programs.git-identity = {
        enable = true;
        workspaces =
          mapAttrs (_name: ws: {
            directory = ws.directory;
            realName = ws.realName;
            email = ws.email;
            gpg = {
              enable = ws.gpg.enable;
              keyId = config.sops.secrets."profiles/${ws.profileName}/gpg/key_id".path;
            };
            ssh = {
              enable = ws.ssh.enable;
              privateKey = config.sops.secrets."profiles/${ws.profileName}/ssh/private_key".path;
            };
          })
          activeWs;
      };

      # 3. Importar llaves GPG al keyring del usuario ───────────────────
      #    Los archivos los descifra sops-nix antes de este script.
      programs.sops.gpg = {
        enable = true;
        keys =
          mapAttrsToList (ws: {
            name = "${ws.profileName}-workspace-key";
            publicKey = config.sops.secrets."profiles/${ws.profileName}/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/${ws.profileName}/gpg/private_key".path;
          })
          (filterAttrs (ws: ws.gpg.enable) activeWs);
      };

      # 4. Sync SSH → GitHub / GitLab cuando la llave cambia ────────────
      #    Corre en postActivation (Darwin) o workspaceIdentitySync (Linux),
      #    DESPUÉS de que sops-nix haya descifrado todos los secrets.
      #    El estado se persiste en /var/lib/git-identity/*.fingerprint.
      system.activationScripts = mkIf hasPlatformSync (
        if pkgs.stdenv.isDarwin
        then {postActivation.text = fullSyncScript;}
        else {workspaceIdentitySync.text = fullSyncScript;}
      );
    };
  };
}
