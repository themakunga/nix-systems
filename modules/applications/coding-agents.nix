# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  self,
  inputs,
  ...
}: {
  flake.applicationModules.coding-agents = self.lib.mkAppModule "coding-agents" "Interactive coding agents with private runtime authentication" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = with pkgs; [unstable.codex claude-code gemini-cli];
    };
    sysConfig = {
      config,
      lib,
      pkgs,
      ...
    }: let
      targets =
        [
          {
            user = config.my.dotfiles.user;
            home = config.my.dotfiles.home;
          }
        ]
        ++ config.my.dotfiles.additionalUsers;
      geminiSecret = "agents/gemini-personal/api_key";
      seed = target: let
        home = target.home;
        commands = ''
          set -eu
          umask 077
          mkdir -p "${home}/.codex" "${home}/.hermes" "${home}/.gemini" "${home}/.config/gh"
          chmod 700 "${home}/.codex" "${home}/.hermes" "${home}/.gemini" "${home}/.config/gh"
          if [ ! -e "${home}/.config/gh/config.yml" ] && [ ! -L "${home}/.config/gh/config.yml" ]; then
            install -m 600 "${home}/.public-dotfiles/gh/config.aperture-science.yml" "${home}/.config/gh/config.yml"
          fi
          # OAuth refresh rewrites this file; seed once and preserve runtime credentials.
          if [ ! -e "${home}/.codex/auth.json" ] && [ ! -L "${home}/.codex/auth.json" ]; then
            install -m 600 ${config.sops.secrets.codex-auth.path} "${home}/.codex/auth.json"
          fi
          if [ ! -e "${home}/.hermes/config.yaml" ] && [ ! -L "${home}/.hermes/config.yaml" ]; then
            install -m 600 "${home}/.public-dotfiles/hermes/config.aperture-science.yaml" "${home}/.hermes/config.yaml"
          fi
          ln -sfn ${config.sops.templates."coding-agents-env".path} "${home}/.hermes/.env"
        '';
      in ''
        /run/wrappers/bin/sudo -H -u ${lib.escapeShellArg target.user} ${pkgs.runtimeShell} -c ${lib.escapeShellArg commands}
      '';
    in {
      programs.git = {
        enable = true;
        config.credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
      users.groups.coding-agents.members = map (target: target.user) targets;
      sops.secrets = {
        "applications/gh/token" = {
          sopsFile = "${inputs.secrets.outPath}/shared-conf/aperture/gh-token";
          format = "binary";
          owner = "root";
          group = "coding-agents";
          mode = "0440";
        };
        ${geminiSecret} = {
          sopsFile = "${inputs.secrets.outPath}/common.yaml";
          owner = "root";
          group = "coding-agents";
          mode = "0440";
        };
        codex-auth = {
          sopsFile = "${inputs.secrets.outPath}/shared-conf/codex/auth.json";
          format = "binary";
          owner = "root";
          group = "coding-agents";
          mode = "0440";
        };
      };
      sops.templates."coding-agents-env" = {
        owner = "root";
        group = "coding-agents";
        mode = "0440";
        content = ''
          GEMINI_API_KEY=${config.sops.placeholder.${geminiSecret}}
        '';
      };
      environment.interactiveShellInit = ''
        if [ -r ${config.sops.secrets.${geminiSecret}.path} ]; then
          export GEMINI_API_KEY="$(cat ${config.sops.secrets.${geminiSecret}.path})"
        fi
      '';
      system.activationScripts = {
        agent-wiki-setup.deps = ["seedCodingAgents"];
        claude-hooks-setup.deps = ["agent-wiki-setup"];
        seedCodingAgents = {
          deps =
            ["users" "setupSecrets"]
            ++ map (target:
              if target.user == config.my.dotfiles.user
              then "stowDotfiles"
              else "stowDotfiles-${target.user}")
            targets;
          text = lib.concatMapStringsSep "\n" seed targets;
        };
      };
    };
  };
}
