# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-admin = {config, ...}: {
    imports = [
      commonModules.home-secrets
    ];

    sops.secrets."passwords/nicolas-admin/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-admin = {
      username = "nicolas";
      fullName = "Nicolas Admin";
      email = "nicolas-admin@local";
      description = "Nicolas - admin manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas-admin/hashed".path;
      extraGroups = ["docker"];
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    system.activationScripts.postActivation.text = ''
      mkdir -p /opt/nicolas
      chown -R nicolas:staff /opt/nicolas 2>/dev/null || chown -R nicolas:nicolas /opt/nicolas || true
      chmod 700 /opt/nicolas
    '';
  };
}
