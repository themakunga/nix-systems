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
  flake.commonModules.dotfiles = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.dotfiles;
    user = config.system.primaryUser or "nicolas";
    isDarwin = config.system.darwin or false;
    userHome =
      if isDarwin
      then "/Users/${user}"
      else "/home/${user}";
  in {
    options.my.dotfiles = {
      enable = mkEnableOption "Habilitar sincronización y despliegue avanzado de dotfiles";
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
              description = "El nombre del paquete (carpeta) dentro de public-dotfiles.";
            };
            isConfig = mkOption {
              type = types.bool;
              default = false;
              description = "Si es true, hace el stow directamente en ~/.config";
            };
            output-name = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Re-escribe el nombre de la carpeta destino.";
            };
            output-path = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Forza el stow hacia una ruta absoluta específica.";
            };
          };
        });
        default = [];
        description = "Lista de paquetes a desplegar usando GNU Stow.";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [pkgs.stow pkgs.git pkgs.gh];

      system.activationScripts.stowDotfiles = {
        text = ''
          DOTFILES_DIR="${cfg.path}"
          REPO_URL="${cfg.repository}"
          USER_HOME="${userHome}"
          USER="${user}"

          echo "=> Sincronizando repositorio public-dotfiles en $DOTFILES_DIR..."
          if [ ! -d "$DOTFILES_DIR/.git" ]; then
            echo "Clonando repositorio..."
            sudo -u $USER ${pkgs.git}/bin/git clone "$REPO_URL" "$DOTFILES_DIR"
          else
            cd "$DOTFILES_DIR"
            sudo -u $USER ${pkgs.git}/bin/git fetch origin main

            LOCAL_DIFF=$(sudo -u $USER ${pkgs.git}/bin/git status --porcelain)
            AHEAD=$(sudo -u $USER ${pkgs.git}/bin/git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")
            BEHIND=$(sudo -u $USER ${pkgs.git}/bin/git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")

            if [ -n "$LOCAL_DIFF" ] || [ "$AHEAD" -gt 0 ]; then
              echo "Cambios locales detectados. Generando sincronización automática..."
              DATE_STR=$(date +%Y%m%d%H%M%S)
              BRANCH_NAME="chore/sync-$DATE_STR"

              sudo -u $USER ${pkgs.git}/bin/git checkout -b "$BRANCH_NAME"
              sudo -u $USER ${pkgs.git}/bin/git add .
              sudo -u $USER ${pkgs.git}/bin/git commit -m "chore: sync local dotfiles changes from host" || true
              sudo -u $USER ${pkgs.git}/bin/git push -u origin "$BRANCH_NAME" || true

              if command -v ${pkgs.gh}/bin/gh >/dev/null 2>&1; then
                PR_EXISTS=$(sudo -u $USER ${pkgs.gh}/bin/gh pr list --head "$BRANCH_NAME" --json id --jq 'length' 2>/dev/null || echo "0")
                if [ "$PR_EXISTS" -eq "0" ]; then
                  sudo -u $USER ${pkgs.gh}/bin/gh pr create --base develop --head "$BRANCH_NAME" --title "chore: sync dotfiles from host" --body "Automated PR syncing local dotfiles changes." || echo "Fallo al crear PR (requiere autenticación)."
                fi
              fi
              # Se recomienda resolver los PRs y hacer pull para mantener main sincronizado.
              sudo -u $USER ${pkgs.git}/bin/git checkout main
            elif [ "$BEHIND" -gt 0 ]; then
              echo "Actualizando cambios desde origin/main..."
              sudo -u $USER ${pkgs.git}/bin/git pull origin main
            else
              echo "Dotfiles actualizados."
            fi
          fi

          echo "=> Evaluando despliegue de paquetes con Stow..."
          ${builtins.concatStringsSep "\n" (builtins.map (pkg: ''
              PKG_NAME="${pkg.name}"
              IS_CONFIG="${
                if pkg.isConfig
                then "1"
                else "0"
              }"
              OUT_NAME="${
                if pkg.output-name != null
                then pkg.output-name
                else ""
              }"
              OUT_PATH="${
                if pkg.output-path != null
                then pkg.output-path
                else ""
              }"

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
                sudo -u $USER mkdir -p "$TARGET_DIR"
                sudo -u $USER ${pkgs.stow}/bin/stow -t "$TARGET_DIR" -d "$DOTFILES_DIR" --adopt "$PKG_NAME"
              else
                echo "Advertencia: El paquete $PKG_NAME no existe en $DOTFILES_DIR."
              fi
            '')
            cfg.packages)}
        '';
      };
    };
  };
}
