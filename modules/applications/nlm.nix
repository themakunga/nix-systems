# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.nlm = mkAppModule "nlm" "Enable NotebookLM CLI (tmc/nlm)" {
    meta = {
      pkgs,
      lib,
      ...
    }: {
      level = "system";
      packages = [
        (pkgs.buildGoModule {
          pname = "nlm";
          version = "0.1.1-unstable-2026-10-01";
          src = pkgs.fetchFromGitHub {
            owner = "tmc";
            repo = "nlm";
            rev = "7a173b4de23d50221fbc5895df3f201880ccb9d1";
            hash = "sha256-8Eoa7A9koJL+PvmyBolhTcFC0iA80NkEj+2HDsdSNJA=";
          };
          vendorHash = lib.fakeHash;
          doCheck = false;
          subPackages = ["cmd/nlm"];
          meta = {
            description = "CLI and MCP server for NotebookLM";
            homepage = "https://github.com/tmc/nlm";
            license = lib.licenses.mit;
            mainProgram = "nlm";
          };
        })
      ];
    };

    sysConfig = {
      config,
      options,
      ...
    }: let
      secretsFile = "${inputs.secrets.outPath}/common.yaml";
      isDarwin = options ? system.darwin;
      username =
        if isDarwin
        then config.my.primaryUser.username
        else "nicolas";
    in {
      sops.secrets."applications/nlm/auth_token" = {
        owner = username;
        sopsFile = secretsFile;
      };
      sops.secrets."applications/nlm/cookies" = {
        owner = username;
        sopsFile = secretsFile;
      };

      environment.interactiveShellInit = ''
        export NLM_AUTH_TOKEN="$(cat ${config.sops.secrets."applications/nlm/auth_token".path} 2>/dev/null)"
        export NLM_COOKIES="$(cat ${config.sops.secrets."applications/nlm/cookies".path} 2>/dev/null)"
      '';
    };
  };
}
