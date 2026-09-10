# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo: userModules/nicolas
# Description: Usuario administrador Nicolas — acceso SSH con llave,
#              sudo vía wheel, sin home directory.
#              Password bloqueado hasta que el usuario lo configure
#              manualmente en el primer login via SSH.
# =========================================================
{
  flake.userModules.nicolas = {
    lib,
    pkgs,
    ...
  }: {
    my.userProfiles.nicolas = {
      username = "nicolas";
      fullName = "Nicolas Villarroel";
      description = "System Administrator";
      isSystem = false;
      isAdmin = true; # → grupo wheel (sudo)
      isNetworkManager = false;
      createHome = false; # sin home directory
      shell = pkgs.bashInteractive;
      extraGroups = ["docker"];
    };

    # Sin home directory: redirigir a /var/empty (convención UNIX)
    users.users.nicolas.home = lib.mkForce "/var/empty";

    # Contraseña de bootstrap — DEBE cambiarse en el primer acceso.
    # NOTA DE SEGURIDAD: initialPassword queda en texto plano en el Nix store
    # (world-readable). Migrar a SOPS hashedPasswordFile una vez que
    # los secretos del host estén configurados.
    users.users.nicolas.initialPassword = "aperture";

    # Expirar la contraseña inmediatamente para forzar cambio en el primer
    # login interactivo (consola o SSH con PasswordAuthentication).
    # El acceso via llave SSH no se ve afectado por esto.
    system.activationScripts.nicolas-expire-password.text = ''
      if id nicolas &>/dev/null && [ -f /etc/shadow ]; then
        chage -d 0 nicolas 2>/dev/null || true
      fi
    '';
  };
}
