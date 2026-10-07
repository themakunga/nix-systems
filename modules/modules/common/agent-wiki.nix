# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: commonModules.agent-wiki
# Clona el vault privado (agent-wiki) para el usuario primario
# y conecta agent/SOUL.md → vault/agents/SOUL.md.
# Idempotente: git pull si ya existe, clone si no.
_: {
  flake.commonModules.agent-wiki = {
    config,
    lib,
    pkgs,
    options,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption mkIf types;
    cfg = config.my.agentWiki;
    # NixOS siempre declara options.systemd; nix-darwin nunca.
    # Más confiable que options?launchd bajo cross-compilation.
    isDarwin = !(options ? systemd);
    user = config.system.primaryUser or "nicolas";
    userHome =
      if isDarwin
      then "/Users/${user}"
      else "/home/${user}";

    script = ''
      USER_HOME="${userHome}"
      WIKI_DIR="$USER_HOME/.vaults/agent-wiki"
      WIKI_REPO="git@github.com:themakunga/agent-wiki.git"
      SOUL_LINK="$USER_HOME/.public-dotfiles/agent/SOUL.md"
      ${
        if isDarwin
        then ''run_as_user() { sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
        else ''run_as_user() { /run/wrappers/bin/sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
      }

      # Clone o pull — tolerante a fallo de red (offline, sin SSH key lista)
      if [ ! -d "$WIKI_DIR/.git" ]; then
        echo "=> Clonando agent-wiki para ${user}..."
        run_as_user ${pkgs.git}/bin/git clone "$WIKI_REPO" "$WIKI_DIR" 2>/dev/null || true
      else
        run_as_user ${pkgs.git}/bin/git -C "$WIKI_DIR" pull origin main 2>/dev/null || true
      fi

      # Symlink SOUL.md solo cuando el vault existe
      if [ -f "$WIKI_DIR/agents/SOUL.md" ]; then
        run_as_user mkdir -p "$USER_HOME/.public-dotfiles/agent"
        run_as_user ln -sf "$WIKI_DIR/agents/SOUL.md" "$SOUL_LINK"
      fi
    '';

    syncScript = pkgs.writeShellScript "agent-wiki-sync" ''
      set -euo pipefail
      WIKI_DIR="${userHome}/.vaults/agent-wiki"

      [ -d "$WIKI_DIR/.git" ] || exit 0   # vault no clonado aún

      cd "$WIKI_DIR"

      # Pull (rebase para evitar merge commits automáticos)
      ${pkgs.git}/bin/git pull --rebase origin main 2>/dev/null || true

      # Commit si hay cambios sin commitear
      if ! ${pkgs.git}/bin/git diff --quiet HEAD 2>/dev/null || \
         [ -n "$(${pkgs.git}/bin/git ls-files --others --exclude-standard)" ]; then
        ${pkgs.git}/bin/git add -A
        ${pkgs.git}/bin/git commit -m "vault: auto-sync $(date '+%Y-%m-%d %H:%M:%S')" || true
      fi

      # Push si hay commits locales no enviados
      AHEAD=$(${pkgs.git}/bin/git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)
      [ "$AHEAD" -gt 0 ] && ${pkgs.git}/bin/git push origin main 2>/dev/null || true
    '';
  in {
    options.my.agentWiki = {
      enable = mkEnableOption "Sincronizar vault agent-wiki y cablear SOUL.md para agentes IA";
      autoSync = {
        enable = mkEnableOption "Sync periódico en background via launchd (macOS) / systemd (Linux)";
        interval = mkOption {
          type = types.int;
          default = 300;
          description = "Intervalo de sync en segundos (default: 5 min)";
        };
      };
    };

    config = mkIf cfg.enable (lib.mkMerge [
      {
        environment.systemPackages = [pkgs.git];

        system.activationScripts =
          if isDarwin
          then {postActivation.text = lib.mkAfter script;}
          else {
            agent-wiki-setup = {
              deps = ["stowDotfiles"];
              text = script;
            };
          };
      }

      # ── macOS: launchd user agent ──────────────────────────────────────
      # isDarwin usa hostPlatform (target), no stdenv.isDarwin (build host).
      # Esto evita que cross-compilation Darwin→Linux evalúe `launchd` en NixOS.
      (mkIf (cfg.autoSync.enable && isDarwin) {
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
      })
    ]);
  };
}
