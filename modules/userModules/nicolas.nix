# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: userModules/nicolas
# Description: Usuario administrador Nicolas — acceso SSH con llave,
#              sudo vía wheel, sin home directory.
#              Password hash almacenado en SOPS (secrets/users/nicolas.yaml).
{inputs, ...}: {
  flake.userModules.nicolas = {
    lib,
    pkgs,
    config,
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

    # Password hash almacenado en SOPS — no queda en texto plano en el Nix store.
    # sops-nix descifra el archivo en /run/secrets/nicolas-password en cada activación.
    sops.secrets."nicolas-password" = {
      sopsFile = "${inputs.secrets.outPath}/users/nicolas.yaml";
      format = "yaml";
      key = "password";
      neededForUsers = true; # disponible antes de que se creen los usuarios
    };
    users.users.nicolas.hashedPasswordFile = config.sops.secrets."nicolas-password".path;

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
