# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.glados = {
    lib,
    pkgs,
    ...
  }: let
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  in {
    imports = [
      commonModules.home-secrets
    ];

    users =
      {
        users.glados =
          {
            uid = 466;
            home = "/opt/glados";
            description = lib.mkDefault "Service Account para IA Local";
          }
          // lib.optionalAttrs isDarwin {
            gid = 466; # Darwin usa el ID numérico para el grupo primario
          }
          // lib.optionalAttrs (!isDarwin) {
            group = "glados"; # NixOS usa el nombre del grupo como string
          };

        groups.glados = {gid = 466;};
      }
      // lib.optionalAttrs isDarwin {
        knownUsers = ["glados"];
        knownGroups = ["glados"];
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
      shell = "/usr/sbin/nologin";
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
