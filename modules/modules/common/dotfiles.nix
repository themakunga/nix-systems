# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
_: {
  flake.commonModules.dotfiles = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.dotfiles;
    isDarwin = pkgs.stdenv.isDarwin;
    user = cfg.user;
    userHome =
      if cfg.home != null
      then cfg.home
      else if isDarwin
      then "/Users/${user}"
      else "/home/${user}";

    # Stow loop — shared between Darwin and Linux.
    stowLoop = builtins.concatStringsSep "\n" (builtins.map (pkg: let
        isConfigStr =
          if pkg.isConfig
          then "1"
          else "0";
        outNameStr =
          if pkg.output-name != null
          then pkg.output-name
          else "";
        outPathStr =
          if pkg.output-path != null
          then pkg.output-path
          else "";
      in ''
        PKG_NAME="${pkg.name}"
        IS_CONFIG="${isConfigStr}"
        OUT_NAME="${outNameStr}"
        OUT_PATH="${outPathStr}"
        TARGET_DIR="$USER_HOME"
        if [ -n "$OUT_PATH" ]; then
          TARGET_DIR="$OUT_PATH"
        elif [ "$IS_CONFIG" = "1" ]; then
          TARGET_DIR="$USER_HOME/.config"
        fi
        if [ -n "$OUT_NAME" ]; then
          TARGET_DIR="$TARGET_DIR/$OUT_NAME"
        elif [ "$IS_CONFIG" = "1" ] || [ -n "$OUT_PATH" ]; then
          TARGET_DIR="$TARGET_DIR/$PKG_NAME"
        fi
        if [ -d "$DOTFILES_DIR/$PKG_NAME" ]; then
          echo "Aplicando stow para $PKG_NAME hacia $TARGET_DIR..."
          run_as_user mkdir -p "$TARGET_DIR"
          run_as_user ${pkgs.stow}/bin/stow -t "$TARGET_DIR" -d "$DOTFILES_DIR" --adopt "$PKG_NAME"
        else
          echo "Advertencia: El paquete $PKG_NAME no existe en $DOTFILES_DIR."
        fi
      '')
      cfg.packages);

    # Git sync body — shared between Darwin and Linux.
    # Caller must define: DOTFILES_DIR, REPO_URL, USER_HOME, USER, HOSTNAME, run_as_user().
    gitSync = ''
      echo "=> Sincronizando repositorio public-dotfiles en $DOTFILES_DIR..."
      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo "Clonando repositorio..."
        run_as_user ${pkgs.git}/bin/git clone "$REPO_URL" "$DOTFILES_DIR"
      else
        cd "$DOTFILES_DIR"
        run_as_user ${pkgs.git}/bin/git fetch origin main
        LOCAL_DIFF=$(run_as_user ${pkgs.git}/bin/git status --porcelain)
        AHEAD=$(run_as_user ${pkgs.git}/bin/git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")
        BEHIND=$(run_as_user ${pkgs.git}/bin/git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
        if [ -n "$LOCAL_DIFF" ] || [ "$AHEAD" -gt 0 ]; then
          echo "Cambios locales detectados. Generando sincronización automática..."
          DATE_STR=$(date +%Y%m%d%H%M%S)
          BRANCH_NAME="chore/sync-$DATE_STR"
          run_as_user ${pkgs.git}/bin/git checkout -b "$BRANCH_NAME"
          run_as_user ${pkgs.git}/bin/git add .
          run_as_user ${pkgs.git}/bin/git \
            -c user.name="Nix Auto Sync" \
            -c user.email="$USER@$HOSTNAME" \
            commit -m "chore: sync local dotfiles changes from host" || true
          run_as_user env GIT_TERMINAL_PROMPT=0 ${pkgs.git}/bin/git push -u origin "$BRANCH_NAME" || true
          if command -v ${pkgs.gh}/bin/gh >/dev/null 2>&1; then
            PR_EXISTS=$(run_as_user ${pkgs.gh}/bin/gh pr list --head "$BRANCH_NAME" --json id --jq 'length' 2>/dev/null || echo "0")
            if [ "$PR_EXISTS" -eq "0" ]; then
              run_as_user ${pkgs.gh}/bin/gh pr create --base develop --head "$BRANCH_NAME" --title "chore: sync dotfiles from host" --body "Automated PR syncing local dotfiles changes." || echo "Fallo al crear PR (requiere autenticación)."
            fi
          fi
          run_as_user ${pkgs.git}/bin/git checkout main
        elif [ "$BEHIND" -gt 0 ]; then
          echo "Actualizando cambios desde origin/main..."
          run_as_user ${pkgs.git}/bin/git pull origin main
        else
          echo "Dotfiles actualizados."
        fi
      fi
      echo "=> Evaluando despliegue de paquetes con Stow..."
      ${stowLoop}
    '';

    darwinScript = ''
      DOTFILES_DIR="${cfg.path}"
      REPO_URL="${cfg.repository}"
      USER_HOME="${userHome}"
      USER="${user}"
      HOSTNAME=$(hostname)
      run_as_user() { sudo -H -u "$USER" env HOME="$USER_HOME" "$@"; }
      ${gitSync}
    '';

    linuxScript = ''
      DOTFILES_DIR="${cfg.path}"
      REPO_URL="${cfg.repository}"
      USER_HOME="${userHome}"
      USER="${user}"
      HOSTNAME=$(cat /etc/hostname 2>/dev/null || echo "nixos")
      run_as_user() { /run/wrappers/bin/sudo -H -u "$USER" env HOME="$USER_HOME" "$@"; }
      mkdir -p "$USER_HOME" "$USER_HOME/.config"
      chown "$USER" "$USER_HOME" "$USER_HOME/.config" 2>/dev/null || true
      chmod 755 "$USER_HOME" "$USER_HOME/.config" 2>/dev/null || true
      ${gitSync}
    '';
  in {
    options.my.dotfiles = {
      enable = mkEnableOption "Habilitar sincronización y despliegue avanzado de dotfiles";
      user = mkOption {
        type = types.str;
        default = config.system.primaryUser or "nicolas";
        description = "Usuario que recibirá los dotfiles";
      };
      home = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Ruta home del usuario. null → /Users/<user> en Darwin, /home/<user> en Linux.";
      };
      repository = mkOption {
        type = types.str;
        default = "https://github.com/themakunga/public-dotfiles.git";
        description = "URL del repositorio de public-dotfiles";
      };
      path = mkOption {
        type = types.str;
        default = "${userHome}/.public-dotfiles";
        description = "Ruta local donde residirá el repositorio";
      };
      packages = mkOption {
        type = types.listOf (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Nombre del paquete (carpeta) dentro de public-dotfiles.";
            };
            isConfig = mkOption {
              type = types.bool;
              default = false;
              description = "Si true, stow hacia ~/.config/<name>.";
            };
            output-name = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Re-escribe el nombre de la carpeta destino.";
            };
            output-path = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Fuerza el stow hacia una ruta absoluta específica.";
            };
          };
        });
        default = [];
        description = "Lista de paquetes a desplegar usando GNU Stow.";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [pkgs.stow pkgs.git pkgs.gh];

      system.activationScripts =
        if isDarwin
        then {postActivation.text = darwinScript;}
        else {stowDotfiles.text = linuxScript;};
    };
  };
}
