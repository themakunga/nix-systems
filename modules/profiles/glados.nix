# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.glados = {
    config,
    pkgs,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) isDarwin;

    # Extraemos tu usuario de forma segura
    primaryUserName = config.my.primaryUser.username or "nicolas";

    # LA MAGIA ESTÁ AQUÍ: Si es macOS, tú eres el dueño. Si es Linux, es GLaDOS.
    secretOwner =
      if isDarwin
      then primaryUserName
      else "glados";

    sopsConf = {
      owner = secretOwner;
    };

    # Helpers para las rutas dinámicas de SOPS
    gladosSecrets = {
      sshKey = config.sops.secrets."profiles/glados/ssh/private_key".path;
      gpgPriv = config.sops.secrets."profiles/glados/gpg/private_key".path;
      gpgPub = config.sops.secrets."profiles/glados/gpg/public_key".path;
      gpgId = config.sops.secrets."profiles/glados/gpg/key_id".path;
    };
  in {
    sops.secrets = {
      "profiles/glados/ssh/private_key" = sopsConf;
      "profiles/glados/gpg/private_key" = sopsConf;
      "profiles/glados/gpg/public_key" = sopsConf;
      "profiles/glados/gpg/key_id" = sopsConf;
    };

    # Asignamos las herramientas de IA
    my.apps.glados-tools = {
      enable = true;
      level =
        if isDarwin
        then "user"
        else "system";
      targetUser =
        if isDarwin
        then primaryUserName
        else "glados";
      packages = with pkgs; [
        ollama
        # zeroclaw
      ];
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "glados-key";
            publicKey = gladosSecrets.gpgPub;
            privateKey = gladosSecrets.gpgPriv;
          }
        ];
      };

      git-identity = {
        enable = true;
        workspaces.zeroclaw = {
          directory = "/opt/glados/**";
          realName = "GLaDOS (ZeroClaw)";
          email = "glados@aperturescience.com";
          gpg = {
            enable = true;
            keyId = gladosSecrets.gpgId;
          };
          ssh = {
            enable = true;
            privateKey = gladosSecrets.sshKey;
          };
        };
      };
    };
  };
}
