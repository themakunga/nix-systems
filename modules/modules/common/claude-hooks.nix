# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: commonModules.claude-hooks
# Retira el Stop hook obsoleto de journal de Claude Code en ~/.claude/settings.json.
_: {
  flake.commonModules.claude-hooks = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.claudeHooks;
    isDarwin = pkgs.stdenv.isDarwin;
    user = config.system.primaryUser or "nicolas";
    userHome =
      if isDarwin
      then "/Users/${user}"
      else "/home/${user}";

    script = ''
            USER_HOME="${userHome}"
            SETTINGS="$USER_HOME/.claude/settings.json"

            ${
        if isDarwin
        then ''run_as_user() { sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
        else ''run_as_user() { /run/wrappers/bin/sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
      }

            if [ -f "$SETTINGS" ]; then
              run_as_user ${pkgs.python3}/bin/python3 -c "
      import json, os

      settings_path = os.environ['HOME'] + '/.claude/settings.json'
      with open(settings_path) as f:
          data = json.load(f)

      hooks = data.get('hooks', {})
      current = hooks.get('Stop', [])
      remaining = [entry for entry in current if not any('save-session.py' in hook.get('command', str()) for hook in entry.get('hooks', []))]
      if len(remaining) != len(current):
          if remaining:
              hooks['Stop'] = remaining
          else:
              del hooks['Stop']
          with open(settings_path, 'w') as f:
              print(json.dumps(data, indent=2), file=f)
              "
            fi

            # Codex: enlazar hooks.json si el dotfile existe y el symlink no
            CODEX_HOOKS_SRC="$USER_HOME/.public-dotfiles/codex/hooks.json"
            CODEX_HOOKS_DST="$USER_HOME/.codex/hooks.json"
            if [ -f "$CODEX_HOOKS_SRC" ] && [ ! -e "$CODEX_HOOKS_DST" ]; then
              echo "=> Enlazando Codex hooks.json para ${user}..."
              run_as_user ln -s ../.public-dotfiles/codex/hooks.json "$CODEX_HOOKS_DST"
            fi
    '';
  in {
    options.my.claudeHooks = {
      enable = mkEnableOption "Retirar el Stop hook obsoleto de journal de Claude Code";
    };

    config = mkIf cfg.enable {
      system.activationScripts =
        if isDarwin
        then {
          postActivation.text = lib.mkAfter script;
        }
        else {
          claude-hooks-setup = {
            deps = ["stowDotfiles"];
            text = script;
          };
        };
    };
  };
}
