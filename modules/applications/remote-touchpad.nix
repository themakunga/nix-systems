# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.remote-touchpad =
    self.lib.mkAppModule "remote-touchpad"
    "iPad como teclado/touchpad via uinput" {
      meta = {level = "system";};
      sysConfig = {pkgs, ...}: let
        # Override: compilar solo con backend uinput (Wayland no necesita portal ni x11).
        # vendorHash sin cambio — los tags de Go no afectan el directorio vendor.
        remote-touchpad-uinput = pkgs.remote-touchpad.overrideAttrs (_: {
          tags = ["uinput"];
        });
      in {
        # Módulo kernel uinput + regla udev: GROUP="uinput" MODE="0660"
        hardware.uinput.enable = true;

        # Puerto 9000 está ocupado por Portainer (containers.nix) — usar 9100.
        # El router no tiene port forwarding: este puerto solo es accesible en LAN.
        networking.firewall.allowedTCPPorts = [9100];

        # Disponible en PATH para prueba manual: remote-touchpad -bind IP:9100
        environment.systemPackages = [remote-touchpad-uinput];

        # Servicio de usuario: arranca con la sesión gráfica de Hyprland
        # y se detiene cuando la sesión termina (PartOf= garantiza esto).
        systemd.user.services.remote-touchpad = {
          description = "Remote Touchpad — iPad input server (uinput backend)";
          # default.target: arranca con la sesión de usuario (no requiere graphical-session,
          # que greetd+Hyprland no activa correctamente en esta configuración).
          wantedBy = ["default.target"];
          after = ["default.target"];

          # kbd: necesario si remote-touchpad llama loadkeys para el mapa de teclado.
          path = [pkgs.openssl pkgs.coreutils pkgs.kbd];

          # Genera el secreto en el primer arranque; persiste entre reinicios.
          # El QR muestra la URL completa incluyendo el secreto como fragmento (#secret).
          # Guarda esa URL en Favoritos de Safari para reconectar sin re-escanear.
          preStart = ''
            mkdir -p "$HOME/.config/remote-touchpad"
            chmod 700 "$HOME/.config/remote-touchpad"
            SECRET_FILE="$HOME/.config/remote-touchpad/secret"
            if [ ! -f "$SECRET_FILE" ]; then
              openssl rand -base64 32 | tr -d '=/+' | head -c 32 > "$SECRET_FILE"
              chmod 600 "$SECRET_FILE"
            fi
          '';

          script = ''
            SECRET=$(cat "$HOME/.config/remote-touchpad/secret")
            # AVISO DE SEGURIDAD: -secret es visible en 'ps aux' — limitación de la app.
            # La URL protege el acceso pero el tráfico no está cifrado (HTTP).
            # Usar exclusivamente en red local confiable.
            exec ${remote-touchpad-uinput}/bin/remote-touchpad \
              -bind 0.0.0.0:9100 \
              -secret "$SECRET"
          '';

          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };
      };
    };
}
