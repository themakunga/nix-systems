# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: commonModules.claude-hooks
# Asegura el Stop hook de journal de Claude Code en ~/.claude/settings.json.
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

      ${
        if isDarwin
        then ''run_as_user() { sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
        else ''run_as_user() { /run/wrappers/bin/sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
      }

      # Garantiza el Stop hook del journal; el script vive en amgmt.
      HOOK="$USER_HOME/.vaults/amgmt/hooks/ensure-claude-hook.py"
      if [ -f "$HOOK" ]; then
        run_as_user ${pkgs.python3}/bin/python3 "$HOOK" || true
      fi
    '';
  in {
    options.my.claudeHooks = {
      enable = mkEnableOption "Asegurar el Stop hook de journal de Claude Code";
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
