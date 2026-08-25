# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Wallpaper management module for NixOS and Darwin.
# Copies the source image to ~/.config/wallpapers/ and applies it on activation.
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
      enable = mkEnableOption "Automatic wallpaper management";

      path = mkOption {
        type = types.oneOf [types.path types.str];
        description = "Source image path (e.g. \${self}/media/wp/kanagawa-fullsize.jpg).";
      };

      fileName = mkOption {
        type = types.str;
        default = "wallpaper.jpg";
        description = "Destination filename inside ~/.config/wallpapers/.";
      };
    };

    config = mkIf cfg.enable {
      system.activationScripts = {
        postActivation.text = lib.mkAfter ''
          echo "=> Syncing wallpaper to ${wallpaperTargetDir}..."

          SRC_PATH="${toString cfg.path}"
          TARGET_FILE="${wallpaperTargetDir}/${cfg.fileName}"

          if [ -f "$SRC_PATH" ]; then
            mkdir -p "${wallpaperTargetDir}"
            cp -f "$SRC_PATH" "$TARGET_FILE"
            chmod 644 "$TARGET_FILE"
            chown "${targetUser}" "$TARGET_FILE" 2>/dev/null || true

            ${lib.optionalString isDarwin ''
            echo "=> Applying wallpaper from $TARGET_FILE..."
            sudo -u "${targetUser}" osascript -e "tell application \"System Events\" to set picture of every desktop to \"$TARGET_FILE\"" 2>/dev/null || true
          ''}
          else
            echo "Error: wallpaper source not found at '$SRC_PATH'"
          fi
        '';
        wallpaper.text = mkIf isDarwin ''
          echo "=> Applying wallpaper on all displays..."
          osascript -e 'tell application "System Events" to tell every desktop to set picture to "${cfg.path}"'
        '';
      };

      environment.systemPackages = lib.mkIf (!isDarwin) (with pkgs; [
        swww
      ]);
    };
  };
}
