# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
_: {
  flake.applicationModules.agent-workspace = {
    config,
    lib,
    pkgs,
    options,
    ...
  }: let
    enabled =
      builtins.any (name: config.my.apps.${name}.enable or false)
      ["codex" "claude-code" "opencode" "gemini-cli" "hermes" "agent-workspace"];
    isDarwin = options ? launchd;
    user = config.my.dotfiles.user;
    home =
      if config.my.dotfiles.home != null
      then config.my.dotfiles.home
      else
        (
          if isDarwin
          then "/Users/${user}"
          else "/home/${user}"
        );
    targets = lib.unique ([{inherit user home;}]
      ++ config.my.agentWiki.additionalUsers
      ++ lib.optionals (!isDarwin && config.users.users ? glados) [
        {
          user = "glados";
          home = config.users.users.glados.home;
        }
      ]
      ++ lib.optionals (!isDarwin && config.users.users ? hermes) [
        {
          user = "hermes";
          home = config.users.users.hermes.home;
        }
      ]);
    skills = pkgs.callPackage ../../packages/agent-skills/package.nix {};
    ub = (pkgs.callPackage ../../packages/ub-mode/package.nix {}).skill;
    path = lib.makeBinPath [pkgs.python3 pkgs.lua pkgs.taplo pkgs.jq pkgs.git pkgs.gh pkgs.coreutils];
    token = config.my.agentWiki.githubTokenFile;
    seed = target: let
      userHome =
        if target.home != null
        then target.home
        else
          (
            if isDarwin
            then "/Users/${target.user}"
            else "/home/${target.user}"
          );
    in ''
      (
        set -euo pipefail
        run_as_user() {
          ${
        if isDarwin
        then "sudo"
        else "/run/wrappers/bin/sudo"
      } -H -u ${lib.escapeShellArg target.user} \
            env HOME=${lib.escapeShellArg userHome} PATH="${path}:$PATH" "$@"
        }
        test -f ${lib.escapeShellArg "${home}/.public-dotfiles/agent/shared-workspace.py"}
        run_as_user ${pkgs.python3}/bin/python3 - \
          --home ${lib.escapeShellArg userHome} \
          --skills ${skills} --ub-skill ${ub} \
          --dotfiles-repository ${lib.escapeShellArg config.my.dotfiles.repository} \
          ${lib.optionalString (token != null) "--token-file ${lib.escapeShellArg token}"} \
          --settings "$(cat ${lib.escapeShellArg "${home}/.public-dotfiles/agent/journal-settings.json"})" \
          < ${lib.escapeShellArg "${home}/.public-dotfiles/agent/shared-workspace.py"}
      )
    '';
    script = lib.concatMapStringsSep "\n" seed targets;
  in {
    config = lib.mkIf enabled {
      environment.systemPackages = with pkgs; [python3 (lib.lowPrio lua) taplo jq git gh];
      system.activationScripts =
        if isDarwin
        then {
          # The shared vault's mkAfter setup must finish before importing its skills.
          postActivation.text = lib.mkOrder 1600 script;
        }
        else {
          seedAgentWorkspace = {
            deps =
              ["users" "setupSecrets" "stowDotfiles" "agent-wiki-setup"]
              ++ lib.optional (config.my.apps.ub-mode.enable or false) "seedUbMode"
              ++ lib.optional (config.system.activationScripts ? glados-agent-dotfiles) "glados-agent-dotfiles"
              ++ lib.optional (config.system.activationScripts ? hermes-setup) "hermes-setup";
            text = script;
          };
        };
    };
  };
}
