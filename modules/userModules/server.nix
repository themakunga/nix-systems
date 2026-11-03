# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-server = {config, ...}: {
    imports = [
      commonModules.home-secrets
    ];

    sops.secrets."passwords/nicolas/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-server = {
      username = "nicolas";
      fullName = "Nicolas Server";
      email = "nicolas-server@local";
      description = "Nicolas server - server manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas/hashed".path;
      # Runtime es Podman con dockerCompat (ver applicationModules.podman);
      # el grupo real del socket es "podman", no "docker".
      extraGroups = ["podman"];
    };

    # Podman rootless necesita rangos sub-UID/GID para mapear namespaces de
    # usuario dentro de los contenedores; sin esto /etc/subuid queda vacío
    # y "podman compose up" falla con "no subuid ranges found".
    users.users.nicolas.autoSubUidGidRange = true;

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
