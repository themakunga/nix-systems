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
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.agentWiki;
    isDarwin = pkgs.stdenv.isDarwin;
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
  in {
    options.my.agentWiki = {
      enable = mkEnableOption "Sincronizar vault agent-wiki y cablear SOUL.md para agentes IA";
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [pkgs.git];

      system.activationScripts =
        if isDarwin
        then {
          # Se agrega al final de postActivation para correr después del stow de dotfiles.
          postActivation.text = lib.mkAfter script;
        }
        else {
          # En NixOS, depende de stowDotfiles (que crea ~/.public-dotfiles primero).
          agent-wiki-setup = {
            deps = ["stowDotfiles"];
            text = script;
          };
        };
    };
  };
}
