# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo: userModules/wheatley
# Description: Usuario kiosk para aperture-science.
#              Auto-login vía greetd → Cage + Foot (terminal-kiosk).
#              Sin acceso administrativo ni shell interactiva SSH.
# =========================================================
{
  flake.userModules.wheatley = {
    lib,
    pkgs,
    ...
  }: {
    my.userProfiles.wheatley = {
      username = "wheatley";
      fullName = "Wheatley";
      description = "Hyprland Desktop Autologin User";
      isSystem = false;
      isAdmin = false;
      isNetworkManager = false;
      createHome = true;
      shell = pkgs.bashInteractive;
      # Grupos seat/video/input/render/audio los añade hyprland-desktop automáticamente
      extraGroups = [];
    };

    # Home en /opt — convención para cuentas de servicio/kiosk en aperture-science
    users.users.wheatley.home = lib.mkForce "/opt/wheatley";
  };
}
