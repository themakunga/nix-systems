# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: Wallpaper Manager (Multiplataforma)
# =========================================================
{self, ...}: {
  flake.commonModules.wallpaper = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.wallpaper;

    wallpaperPath = "${self.outPath}/media/wp/${cfg.fileName}";

    isDarwin = pkgs.stdenv.isDarwin;
    isLinux = pkgs.stdenv.isLinux;
  in {
    options.my.wallpaper = {
      enable = mkEnableOption "Habilitar gestor declarativo de Wallpaper";

      fileName = mkOption {
        type = types.str;
        default = "default.jpg";
        example = "cyberpunk.png";
        description = "Nombre del archivo de imagen ubicado en la carpeta media/wp/ del proyecto.";
      };

      targetUser = mkOption {
        type = types.str;
        default = config.my.primaryUser.username or "nicolas";
        description = "Usuario al cual se le aplicará el fondo de pantalla.";
      };
    };

    config = mkIf cfg.enable {
      system.activationScripts.postActivation.text = mkIf isDarwin (lib.mkAfter ''
        echo "=> Aplicando fondo de pantalla (${cfg.fileName}) para macOS..."

        if [ -f "${wallpaperPath}" ]; then
          # Asigna el fondo a todas las pantallas/desktops activos
          sudo -u "${cfg.targetUser}" osascript -e '
            tell application "System Events"
              tell every desktop
                set picture to "${wallpaperPath}"
              end tell
            end tell
          ' || true
        else
          echo "⚠️ Error: No se encontró el fondo de pantalla en ${wallpaperPath}"
        fi
      '');

      environment.systemPackages = mkIf isLinux [
        pkgs.feh
      ];

      system.user.services.set-wallpaper = mkIf isLinux {
        description = "Set wallpaper on startup";
        wantedBy = ["graphical-session.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.feh}/bin/feh --bg-fill ${wallpaperPath}";
        };
      };
    };
  };
}
