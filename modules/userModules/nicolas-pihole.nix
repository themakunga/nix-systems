# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-pihole = {config, ...}: {
    imports = [
      commonModules.home-secrets
    ];

    sops.secrets."passwords/pihole/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-pihole = {
      username = "pihole";
      fullName = "PiHole Admin";
      email = "pihole@local";
      description = "PiHole - server manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/pihole/hashed".path;
      extraGroups = ["docker"];
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    system.activationScripts.postActivation.text = ''
      mkdir -p /opt/pihole
      chown -R pihole:staff /opt/pihole 2>/dev/null || chown -R pihole:pihole /opt/pihole || true
      chmod 700 /opt/pihole
    '';
  };
}
