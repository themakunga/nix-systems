# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# darwinModules.agent-wiki-sync
# Launchd user agent para sincronizar agent-wiki en background.
# Separado de commonModules.agent-wiki para evitar que NixOS
# evalúe la opción `launchd` que no existe en ese contexto.
_: {
  flake.darwinModules.agent-wiki-sync = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf;
    cfg = config.my.agentWiki;
    user = config.system.primaryUser or "nicolas";
    userHome = "/Users/${user}";

    syncScript = pkgs.writeShellScript "agent-wiki-sync" ''
      set -euo pipefail
      WIKI_DIR="${userHome}/.vaults/agent-wiki"

      [ -d "$WIKI_DIR/.git" ] || exit 0   # vault no clonado aún
      status=0
      ${pkgs.python3}/bin/python3 "$WIKI_DIR/scripts/journal_rollup.py" --sync || status=$?
      ${pkgs.python3}/bin/python3 "$WIKI_DIR/scripts/smart_content_sync.py" || status=$?
      exit "$status"
    '';
  in
    mkIf (cfg.enable && cfg.autoSync.enable) {
      launchd.user.agents.agent-wiki-sync = {
        serviceConfig = {
          ProgramArguments = ["/bin/bash" "${syncScript}"];
          EnvironmentVariables = {
            HOME = userHome;
            # Key explícita: bypasea SSH config (sobreescrita por secret-dotfiles en rebuild)
            GIT_SSH_COMMAND = "/usr/bin/ssh -i ${userHome}/.ssh/id_ed25519 -o UseKeychain=yes -o AddKeysToAgent=yes -o StrictHostKeyChecking=accept-new";
            PATH = "/run/current-system/sw/bin:/usr/bin:/bin";
          };
          StartInterval = cfg.autoSync.interval;
          RunAtLoad = true;
          StandardOutPath = "/tmp/agent-wiki-sync.log";
          StandardErrorPath = "/tmp/agent-wiki-sync-error.log";
        };
      };
    };
}
