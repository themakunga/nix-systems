# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.media = {
    imports = [
      commonModules.home-secrets
    ];

    my.userProfiles.media = {
      username = "media";
      fullName = "Media Server";
      email = "media@local";
      description = "Media Server User - own config";
      isSystem = true;
      isAdmin = false;
      isNetworkManager = true;
      extraGroups = ["docker"];
      createHome = true;
      shell = "/usr/bin/false";
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    system.activationScripts.postActivation.text = ''
      mkdir -p /opt/media
      chown -R media:staff /opt/media 2>/dev/null || chown -R media:media /opt/media || true
      chmod 700 /opt/media
    '';
  };
}
