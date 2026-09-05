# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Wallpaper management module for NixOS and Darwin.
# - Darwin:  copia a ~/.config/wallpapers/ y aplica via osascript en activación.
# - NixOS:   copia a ~/.config/wallpapers/ y aplica via swww en sesión Wayland
#            (Hyprland) mediante dos servicios systemd de usuario:
#              • swww-daemon  — daemon persistente, arranca con graphical-session.target
#              • wallpaper-apply — oneshot que llama a `swww img` una vez el daemon listo
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

    # 'swww' fue renombrado a 'awww' en nixpkgs 26.05
    swwwPkg = pkgs.awww;
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

    config = mkIf cfg.enable (lib.mkMerge [
      {
        # ── Copia del archivo (ambas plataformas) + aplicación en Darwin ────────
        system.activationScripts =
          {
            postActivation.text = lib.mkAfter ''
              echo "=> Syncing wallpaper to ${wallpaperTargetDir}..."

              SRC_PATH="${toString cfg.path}"
              TARGET_FILE="${wallpaperTargetDir}/${cfg.fileName}"

              if [ -f "$SRC_PATH" ]; then
                mkdir -p "${wallpaperTargetDir}"
                # Asegurar que el home y el directorio pertenecen al usuario.
                # Este script corre como root — sin este chown, scripts posteriores
                # que escriban en el home como el usuario (ej: dotfiles) fallarán.
                chown "${targetUser}" "${userHome}" 2>/dev/null || true
                chown -R "${targetUser}" "${wallpaperTargetDir}" 2>/dev/null || true
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
          }
          # Script dedicado solo en Darwin — usar optionalAttrs para evitar que
          # mkIf deje el atributo 'text' sin valor en NixOS (error de evaluación).
          // lib.optionalAttrs isDarwin {
            wallpaper.text = ''
              echo "=> Applying wallpaper on all displays..."
              osascript -e 'tell application "System Events" to tell every desktop to set picture to "${cfg.path}"'
            '';
          };
      }

      # ── Linux / Wayland (Hyprland) ──────────────────────────────────────────
      # Envuelto en mkIf al nivel del bloque para que 'systemd' no sea evaluado
      # por el módulo Darwin — nix-darwin no declara esa opción en absoluto.
      (lib.mkIf (!isDarwin) {
        environment.systemPackages = [swwwPkg];

        # Daemon swww: arranca junto con la sesión gráfica y se mantiene vivo.
        systemd.user.services.swww-daemon = {
          description = "swww wallpaper daemon (Wayland/Hyprland)";
          after = ["graphical-session-pre.target"];
          partOf = ["graphical-session.target"];
          wantedBy = ["graphical-session.target"];
          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            RestartSec = "3s";
            ExecStart = "${swwwPkg}/bin/swww-daemon";
          };
        };

        # Oneshot: espera al daemon y aplica el wallpaper.
        # Usa la ruta del nix store (cfg.path) — legible por cualquier usuario.
        systemd.user.services.wallpaper-apply = {
          description = "Aplicar wallpaper via swww al iniciar sesión Wayland";
          after = ["graphical-session.target" "swww-daemon.service"];
          wants = ["swww-daemon.service"];
          wantedBy = ["graphical-session.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            # Dar tiempo al daemon para que inicialice el socket
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
            ExecStart = "${swwwPkg}/bin/swww img ${toString cfg.path} --transition-type none";
          };
        };
      })
    ]);
  };
}
