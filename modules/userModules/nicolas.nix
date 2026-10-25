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
    pkgs,
    config,
    ...
  }: {
    # Password hash almacenado en SOPS — no queda en texto plano en el Nix store.
    # sops-nix descifra el archivo en /run/secrets/nicolas-password en cada activación.
    sops.secrets."nicolas-password" = {
      sopsFile = "${inputs.secrets.outPath}/users/nicolas.yaml";
      format = "yaml";
      key = "password";
      neededForUsers = true; # disponible antes de que se creen los usuarios
    };

    my.userProfiles.nicolas = {
      username = "nicolas";
      fullName = "Nicolas Villarroel";
      description = "System Administrator";
      isSystem = false;
      isAdmin = true; # → grupo wheel (sudo)
      isNetworkManager = false;
      createHome = true;
      shell = pkgs.bashInteractive;
      extraGroups = ["docker"];
      # Propagar vía userProfiles para no conflictuar con el default null
      hashedPasswordFile = config.sops.secrets."nicolas-password".path;
    };
  };
}
