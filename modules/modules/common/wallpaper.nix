# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: wallpaper (Copia local en $HOME/.config/wallpapers)
# =========================================================
{
  flake.commonModules.wallpaper = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types mkEnableOption mkIf;
    cfg = config.my.wallpaper;
    isDarwin = pkgs.stdenv.isDarwin;

    targetUser = config.my.primaryUser.username or "nicolas";
    userHome =
      if isDarwin
      then "/Users/${targetUser}"
      else "/home/${targetUser}";
    wallpaperTargetDir = "${userHome}/.config/wallpapers";
  in {
    options.my.wallpaper = {
      enable = mkEnableOption "Habilitar gestión automática de fondo de pantalla";

      path = mkOption {
        type = types.oneOf [types.path types.str];
        description = "Ruta al archivo de imagen (ej. \${self}/media/wp/kanagawa-fullsize.jpg).";
      };

      fileName = mkOption {
        type = types.str;
        default = "wallpaper.jpg";
        description = "Nombre del archivo de destino dentro de ~/.config/wallpapers/";
      };
    };

    config = mkIf cfg.enable {
      system.activationScripts.postActivation.text = lib.mkAfter ''
        echo "=> Sincronizando wallpaper en ${wallpaperTargetDir}..."

        SRC_PATH="${toString cfg.path}"
        TARGET_FILE="${wallpaperTargetDir}/${cfg.fileName}"

        if [ -f "$SRC_PATH" ]; then
          mkdir -p "${wallpaperTargetDir}"
          cp -f "$SRC_PATH" "$TARGET_FILE"
          chmod 644 "$TARGET_FILE"
          chown "${targetUser}" "$TARGET_FILE" 2>/dev/null || true

          ${lib.optionalString isDarwin ''
          echo "=> Aplicando wallpaper desde $TARGET_FILE..."
          sudo -u "${targetUser}" osascript -e "tell application \"System Events\" to set picture of every desktop to \"$TARGET_FILE\"" 2>/dev/null || true
        ''}
        else
          echo "Error: No se encontró el archivo de origen del wallpaper en '$SRC_PATH'"
        fi
      '';

      environment.systemPackages = lib.mkIf (!isDarwin) (with pkgs; [
        swww
      ]);
    };
  };
}
