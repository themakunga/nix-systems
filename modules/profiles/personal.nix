# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.personal = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    sopsConf = {
      owner = config.my.userProfiles.personal.username or  "nicolas";
    };
  in {
    sops.secrets = {
      "profiles/personal/ssh/private_key" = sopsConf;
      "profiles/personal/gpg/private_key" = sopsConf;
      "profiles/personal/gpg/public_key" = sopsConf;
      "profiles/personal/gpg/key_id" = sopsConf;
    };

    my = {
      packages = with pkgs; [
        lynx
        btop
        htop
        ctop
        glab
        unstable.typescript # tsc LSP (TypeScript 7 Go rewrite) requires TS 7 on PATH
      ];
      casks = mkIf isDarwin [
        "firefox"
        "firefox@developer-edition"
        "zen"
        "ghostty"
      ];
      brews = [
        "xcode-build-server"
        "espeak-ng" # GLaDOS TTS phonemizer dependency
      ];
      apps.github-cli.enable = true;
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "personal-key";
            publicKey = config.sops.secrets."profiles/personal/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/personal/gpg/private_key".path;
          }
        ];
      };

      # workspaces declarados en el archivo de identidades del host
      git-identity.enable = true;
    };
  };
}
