# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.agent-workspace = self.lib.mkAppModule "agent-workspace" "Shared skills and journal for the primary coding user" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = with pkgs; [lua taplo jq];
    };
    sysConfig = {
      config,
      lib,
      pkgs,
      ...
    }: let
      user = config.my.dotfiles.user;
      home = config.my.dotfiles.home;
      skills = pkgs.callPackage ../../packages/agent-skills/package.nix {};
      token = config.sops.secrets."applications/gh/token".path;
      path = lib.makeBinPath [pkgs.lua pkgs.taplo pkgs.jq pkgs.git pkgs.coreutils];
    in {
      assertions = [
        {
          assertion = config.my.apps.coding-agents.enable && config.my.apps.ub-mode.enable;
          message = "agent-workspace requires coding-agents and ub-mode.";
        }
      ];
      system.activationScripts.seedAgentWorkspace = {
        deps = ["users" "setupSecrets" "stowDotfiles" "seedUbMode" "agent-wiki-setup"];
        text = ''
          (
            set -euo pipefail
            USER_HOME=${lib.escapeShellArg home}
            JOURNAL="$USER_HOME/.vaults/journal"
            WIKI="$USER_HOME/.vaults/amgmt"
            run_as_user() {
              /run/wrappers/bin/sudo -H -u ${lib.escapeShellArg user} env HOME="$USER_HOME" PATH="${path}:$PATH" "$@"
            }
            run_git() {
              run_as_user ${pkgs.runtimeShell} -c '
                export GH_TOKEN="$(cat ${lib.escapeShellArg token})"
                exec "$@"
              ' sh ${pkgs.git}/bin/git -c credential.helper= \
                -c 'credential.helper=!${pkgs.gh}/bin/gh auth git-credential' "$@"
            }
            run_as_user mkdir -p "$USER_HOME/.vaults" "$USER_HOME/Projects" \
              "$USER_HOME/.agents/skills" "$USER_HOME/.codex/skills"
            run_as_user chmod 700 "$USER_HOME/.vaults"
            if [ ! -e "$JOURNAL" ]; then
              run_git clone https://github.com/themakunga/journal.git "$JOURNAL"
            elif [ ! -d "$JOURNAL/.git" ]; then
              echo "Journal path exists but is not a Git repository: $JOURNAL" >&2
              exit 1
            fi
            run_git -C "$JOURNAL" config credential.https://github.com.helper '!${pkgs.gh}/bin/gh auth git-credential'
            run_git -C "$JOURNAL" config user.name GLaDOS
            run_git -C "$JOURNAL" config user.email "GLaDOS@$(hostname -s)"

            for skill in ${skills}/* "$WIKI/skills/agent-glados" "$WIKI/skills/obsidian-journal"; do
              test -f "$skill/SKILL.md"
              name=$(basename "$skill")
              if [ "$name" = agent-glados ]; then name=glados; fi
              destination="$USER_HOME/.agents/skills/$name"
              if [ ! -e "$destination" ] && [ ! -L "$destination" ] && \
                 [ ! -e "$USER_HOME/.codex/skills/$name" ] && [ ! -L "$USER_HOME/.codex/skills/$name" ]; then
                run_as_user ln -s "$skill" "$destination"
              fi
            done

            ${pkgs.jq}/bin/jq -r --arg vault "$JOURNAL" --arg home "$USER_HOME" '
              $vault, "journal", .date_format, .time_format, .agents[], "",
              (.authorized_dirs[] | ($home + "/" + .path), .permissions, (if .enable then "y" else "n" end)), ""
            ' "$USER_HOME/.public-dotfiles/agent/journal-settings.json" |
              run_as_user env PWD="$WIKI/skills/obsidian-journal" \
                ${pkgs.lua}/bin/lua "$WIKI/skills/obsidian-journal/scripts/install.lua"
          )
        '';
      };
    };
  };
}
