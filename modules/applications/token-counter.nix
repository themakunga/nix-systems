# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# token-counter — Terminal TUI for AI token usage and cost tracking
# Package:  inputs.token-counter (own flake)
# Secret:   common.yaml → token-counter.agents.openai
# Written:  ~/.token-counter.yaml (chmod 600) at activation.
{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) mkAppModule;
  secretsFile = "${inputs.secrets.outPath}/common.yaml";
in {
  flake.applicationModules.token-counter = mkAppModule "token-counter" "Terminal TUI for AI token usage and cost" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [inputs.token-counter.packages.${pkgs.system}.default];
    };

    sysConfig = {
      config,
      lib,
      pkgs,
      ...
    }: let
      user = config.system.primaryUser or "nicolas";
      isDarwin = pkgs.stdenv.isDarwin;
      userHome =
        if isDarwin
        then "/Users/${user}"
        else "/home/${user}";
      secretPath = config.sops.secrets."token-counter/agents/openai".path;
    in {
      # Public config → ~/.config/token-counter/config.yaml (via public-dotfiles stow)
      my.dotfiles.packages = [
        {
          name = "token-counter";
          isConfig = true;
        }
      ];

      # Declare secret from common.yaml explicitly (defaultSopsFile points to host yaml)
      sops.secrets."token-counter/agents/openai" = {
        sopsFile = secretsFile;
        owner = user;
        mode = "0400";
      };

      # Write ~/.token-counter.yaml from the decrypted secret at activation
      system.activationScripts =
        if isDarwin
        then {
          postActivation.text = lib.mkAfter ''
            key=$(cat "${secretPath}" 2>/dev/null)
            if [ -n "$key" ]; then
              printf 'agents:\n  openai:\n    api_key: "%s"\n' "$key" \
                > "${userHome}/.token-counter.yaml"
              chmod 600 "${userHome}/.token-counter.yaml"
              chown "${user}" "${userHome}/.token-counter.yaml"
            fi
          '';
        }
        else {
          token-counter-credentials = {
            text = ''
              key=$(cat "${secretPath}" 2>/dev/null)
              if [ -n "$key" ]; then
                printf 'agents:\n  openai:\n    api_key: "%s"\n' "$key" \
                  > "${userHome}/.token-counter.yaml"
                chmod 600 "${userHome}/.token-counter.yaml"
              fi
            '';
          };
        };
    };
  };
}
