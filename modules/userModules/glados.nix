# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  self,
  lib,
  ...
}: let
  inherit (self) commonModules;
in {
  flake.userModules.glados = {
    imports = [
      commonModules.home-secrets
    ];

    users = {
      knownUsers = ["glados"];
      knownGroups = ["glados"];

      users.glados = {
        uid = 466;
        gid = 466;
        home = "/opt/glados";
        description = lib.mkDefault "Service Account para IA Local";
      };

      groups.glados = {gid = 466;};
    };

    my.userProfiles.glados = {
      username = "glados";
      fullName = "GLaDOS";
      email = "glados@aperturescience.com";
      description = "Aperture Science Core AI";
      isSystem = true;
      isAdmin = false;
      isNetworkManager = false;
      extraGroups = ["docker"];
      createHome = false;
      shell = "/usr/sbin/nologin"; # <--- Shell actualizada a nologin
    };

    # Usamos un bloque de activación universal y dejamos que Bash resuelva el SO.
    system.activationScripts.postActivation.text = ''
      echo "=> Configurando la jaula de GLaDOS en /opt/glados..."
      mkdir -p /opt/glados

      if [ "$(uname)" = "Darwin" ]; then
        # En macOS: GLaDOS es la dueña, admin (nicolas) tiene acceso total
        chown -R glados:admin /opt/glados 2>/dev/null || true
        chmod 770 /opt/glados
      else
        # En Linux: Seguridad estricta
        chown -R glados:glados /opt/glados 2>/dev/null || true
        chmod 700 /opt/glados
      fi
    '';
  };
}
