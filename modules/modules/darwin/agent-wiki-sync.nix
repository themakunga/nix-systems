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

      cd "$WIKI_DIR"

      # Pull (rebase para evitar merge commits automáticos)
      ${pkgs.git}/bin/git pull --rebase origin main 2>/dev/null || true

      # Rollup: crea el archivo de hoy, mueve viejos a su semana, crea summaries
      ${pkgs.python3}/bin/python3 "$WIKI_DIR/scripts/journal_rollup.py" --run 2>/dev/null || true

      # Todos los vaults usan los plugins versionados por agent-wiki.
      "$WIKI_DIR/scripts/link-obsidian-plugins.sh" || true

      # Auto-commit del journal y los plugins compartidos (staged o untracked)
      SYNC_PATHS=(journal/ .obsidian/community-plugins.json .obsidian/plugins/)
      SYNC_DIRTY=$(${pkgs.git}/bin/git status --porcelain -- "''${SYNC_PATHS[@]}" 2>/dev/null || true)
      if [ -n "$SYNC_DIRTY" ]; then
        HOSTNAME=$(hostname -s)
        ${pkgs.git}/bin/git add -- "''${SYNC_PATHS[@]}"
        ${pkgs.git}/bin/git \
          -c user.name="GLaDOS" \
          -c user.email="GLaDOS@''${HOSTNAME}" \
          commit -m "vault: auto-sync $(date '+%Y-%m-%d %H:%M:%S')" || true
      fi

      # Push si hay commits locales no enviados
      AHEAD=$(${pkgs.git}/bin/git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
      [ "$AHEAD" -gt 0 ] && ${pkgs.git}/bin/git push origin main 2>/dev/null || true
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
