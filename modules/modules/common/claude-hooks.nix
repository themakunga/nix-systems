# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: commonModules.claude-hooks
# Registra el Stop hook de Claude Code en ~/.claude/settings.json
# para guardar automáticamente un resumen de sesión en el vault.
# Idempotente: solo escribe si el hook no está ya configurado.
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
            HOOK_SCRIPT="$USER_HOME/.claude/scripts/save-session.py"

            ${
        if isDarwin
        then ''run_as_user() { sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
        else ''run_as_user() { /run/wrappers/bin/sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
      }

            if [ -f "$SETTINGS" ]; then
              echo "=> Configurando Claude Code Stop hook para ${user}..."
              run_as_user ${pkgs.python3}/bin/python3 -c "
      import json, os, sys

      settings_path = os.environ['HOME'] + '/.claude/settings.json'
      hook_script   = os.environ['HOME'] + '/.claude/scripts/save-session.py'

      with open(settings_path) as f:
          d = json.load(f)

      expected_hook = {
          'Stop': [{
              'hooks': [{'type': 'command', 'command': f'python3 {hook_script}'}]
          }]
      }

      if d.get('hooks') == expected_hook:
          print('hooks ya configurados')
          sys.exit(0)

      d['hooks'] = expected_hook
      with open(settings_path, 'w') as f:
          json.dump(d, f, indent=2)
      print('hooks actualizados')
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
      enable = mkEnableOption "Registrar Stop hook de Claude Code para guardar sesiones en agent-wiki";
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
