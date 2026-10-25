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
    userHome =
      if cfg.home != null
      then cfg.home
      else if isDarwin
      then "/Users/${cfg.user}"
      else "/home/${cfg.user}";

    # Submodule type for stow package entries — reused for primary and additionalUsers.
    packageSubmodule = types.submodule {
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
    };

    # Generate stow commands for a list of packages.
    # Requires shell vars in scope: $USER_HOME, $DOTFILES_DIR, run_as_user()
    mkStowLoop = packages:
      builtins.concatStringsSep "\n" (builtins.map (pkg: let
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
            run_as_user mkdir -p "$TARGET_DIR"
            CONFLICTS=$(run_as_user ${pkgs.stow}/bin/stow -n -t "$TARGET_DIR" -d "$DOTFILES_DIR" "$PKG_NAME" 2>&1 | grep "existing target is" | ${pkgs.gawk}/bin/awk '{print $NF}' || true)
            if [ -n "$CONFLICTS" ]; then
              for f in $CONFLICTS; do
                run_as_user rm -rf "$TARGET_DIR/$f"
              done
            fi
            run_as_user ${pkgs.stow}/bin/stow -t "$TARGET_DIR" -d "$DOTFILES_DIR" --adopt "$PKG_NAME"
          fi
        '')
        packages);

    # Generate a full deployment script for a single user.
    # Clones the repo if missing, fetches from origin, stows packages.
    # No auto-commit/push: dotfiles are managed via PRs, not activation scripts.
    mkUserScript = {
      user,
      home,
      repoPath,
      packages,
    }: let
      stowLoop = mkStowLoop packages;
    in ''
      USER_HOME="${home}"
      DOTFILES_DIR="${repoPath}"
      REPO_URL="${cfg.repository}"
      ${
        if isDarwin
        then ''run_as_user() { sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
        else ''
          run_as_user() { /run/wrappers/bin/sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }
          mkdir -p "$USER_HOME" "$USER_HOME/.config"
          chown "${user}" "$USER_HOME" "$USER_HOME/.config" 2>/dev/null || true
          chmod 755 "$USER_HOME" "$USER_HOME/.config" 2>/dev/null || true
        ''
      }
      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo "=> Clonando dotfiles para ${user}..."
        run_as_user ${pkgs.git}/bin/git clone "$REPO_URL" "$DOTFILES_DIR"
      fi
      run_as_user ${pkgs.git}/bin/git -C "$DOTFILES_DIR" fetch origin 2>/dev/null || true
      echo "=> Desplegando dotfiles para ${user}..."
      ${stowLoop}
      echo "=> Dotfiles para ${user} desplegados."
    '';

    primaryScript = mkUserScript {
      user = cfg.user;
      home = userHome;
      repoPath = cfg.path;
      packages = cfg.packages;
    };

    # Activation scripts for additional users — each gets a stowDotfiles-<user> script
    # that depends on the primary stowDotfiles and users being set up first.
    additionalUserScripts = builtins.listToAttrs (builtins.map (u: let
        uHome =
          if u.home != null
          then u.home
          else "/home/${u.user}";
      in {
        name = "stowDotfiles-${u.user}";
        value = {
          deps = ["stowDotfiles" "users"];
          text = mkUserScript {
            user = u.user;
            home = uHome;
            repoPath = "${uHome}/.public-dotfiles";
            packages = u.packages;
          };
        };
      })
      cfg.additionalUsers);
  in {
    options.my.dotfiles = {
      enable = mkEnableOption "Habilitar sincronización y despliegue avanzado de dotfiles";
      user = mkOption {
        type = types.str;
        default = config.system.primaryUser or "nicolas";
        description = "Usuario principal que recibirá los dotfiles";
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
        type = types.listOf packageSubmodule;
        default = [];
        description = "Lista de paquetes a desplegar usando GNU Stow.";
      };
      additionalUsers = mkOption {
        type = types.listOf (types.submodule {
          options = {
            user = mkOption {
              type = types.str;
              description = "Nombre del usuario adicional.";
            };
            home = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Ruta home. null → /home/<user>.";
            };
            packages = mkOption {
              type = types.listOf packageSubmodule;
              default = [];
              description = "Paquetes de dotfiles para este usuario.";
            };
          };
        });
        default = [];
        description = "Usuarios adicionales que recibirán dotfiles del mismo repositorio.";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [pkgs.stow pkgs.git pkgs.gawk];

      system.activationScripts =
        if isDarwin
        then {postActivation.text = primaryScript;}
        else {stowDotfiles.text = primaryScript;} // additionalUserScripts;
    };
  };
}
