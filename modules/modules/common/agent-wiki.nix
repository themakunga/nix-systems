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
    ...
  }: let
    inherit (lib) mkEnableOption mkOption mkIf types;
    cfg = config.my.agentWiki;
    isDarwin = pkgs.stdenv.isDarwin;
    # Usuario y home salen de my.dotfiles: nicolas en Darwin, wheatley (/opt/wheatley) en aperture-science.
    user = config.my.dotfiles.user;
    userHome =
      if config.my.dotfiles.home != null
      then config.my.dotfiles.home
      else if isDarwin
      then "/Users/${user}"
      else "/home/${user}";

    script = ''
      USER_HOME="${userHome}"
      WIKI_DIR="$USER_HOME/.vaults/amgmt"
      LEGACY_WIKI_DIR="$USER_HOME/Projects/personal/amgmt"
      WIKI_REPO="git@github.com:themakunga/amgmt.git"
      SOUL_LINK="$USER_HOME/.public-dotfiles/agent/SOUL.md"
      ${
        if isDarwin
        then ''run_as_user() { sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
        else ''run_as_user() { /run/wrappers/bin/sudo -H -u "${user}" env HOME="$USER_HOME" "$@"; }''
      }

      run_as_user mkdir -p "$USER_HOME/.vaults"
      if [ ! -e "$WIKI_DIR" ] && [ ! -L "$WIKI_DIR" ] && [ -d "$LEGACY_WIKI_DIR/.git" ]; then
        run_as_user mv "$LEGACY_WIKI_DIR" "$WIKI_DIR"
        run_as_user ln -s "$WIKI_DIR" "$LEGACY_WIKI_DIR"
      fi

      # Clone o pull — tolerante a fallo de red (offline, sin SSH key lista)
      if [ ! -d "$WIKI_DIR/.git" ]; then
        echo "=> Clonando amgmt para ${user}..."
        run_as_user mkdir -p "$(dirname "$WIKI_DIR")"
        run_as_user ${pkgs.git}/bin/git clone "$WIKI_REPO" "$WIKI_DIR" 2>/dev/null \
          || echo "=> AVISO: no se pudo clonar amgmt para ${user} (¿falta llave SSH de GitHub?); config de agentes sin enlazar."
      else
        run_as_user ${pkgs.git}/bin/git -C "$WIKI_DIR" pull origin main 2>/dev/null || true
      fi

      # Symlink SOUL.md solo cuando el vault existe
      if [ -f "$WIKI_DIR/agents/SOUL.md" ]; then
        run_as_user mkdir -p "$USER_HOME/.public-dotfiles/agent"
        run_as_user ln -sf "$WIKI_DIR/agents/SOUL.md" "$SOUL_LINK"
      fi

      # Config de agentes: todo vive en amgmt; ~/.claude y ~/.codex solo enlazan.
      if [ -d "$WIKI_DIR/hooks" ]; then
        run_as_user mkdir -p "$USER_HOME/.claude/skills" "$USER_HOME/.codex"
        run_as_user ln -sfn "$WIKI_DIR/agents/SOUL.md" "$USER_HOME/.claude/CLAUDE.md"
        run_as_user ln -sfn "$WIKI_DIR/agents/SOUL.md" "$USER_HOME/.codex/AGENTS.md"
        run_as_user ln -sfn "$WIKI_DIR/hooks" "$USER_HOME/.claude/scripts"
        run_as_user ln -sfn "$WIKI_DIR/claude/commands" "$USER_HOME/.claude/commands"
        run_as_user ln -sfn "$WIKI_DIR/codex/hooks.json" "$USER_HOME/.codex/hooks.json"
        run_as_user ln -sfn "$WIKI_DIR/skills/obsidian-journal/SKILL.md" "$USER_HOME/.claude/skills/obsidian-journal.md"
      fi
    '';
  in {
    options.my.agentWiki = {
      enable = mkEnableOption "Sincronizar vault agent-wiki y cablear SOUL.md para agentes IA";
      autoSync = {
        # El servicio de sync en background lo implementa darwinModules.agent-wiki-sync
        # (launchd macOS) o un futuro systemd module (Linux).
        enable = mkEnableOption "Sync periódico en background via launchd (macOS)";
        interval = mkOption {
          type = types.int;
          default = 300;
          description = "Intervalo de sync en segundos (default: 5 min)";
        };
      };
    };

    config = mkIf cfg.enable {
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
    };
  };
}
