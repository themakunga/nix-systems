# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: applicationModules.hermes
# Hermes AI Agent: paquete nativo en Darwin y contenedor rootless en NixOS.
{
  self,
  inputs,
  ...
}: {
  flake.applicationModules.hermes = self.lib.mkAppModule "hermes" "Hermes AI Agent con Obsidian en Podman rootless" {
    meta = {
      pkgs,
      lib,
      options,
      ...
    }: {
      level = "system";
      packages = lib.optionals (options ? homebrew) [
        inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.minimal
      ];
    };

    sysConfig = {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
      if options ? homebrew
      then let
        user = config.system.primaryUser;
        userHome = "/Users/${user}";
        geminiSecret = "agents/gemini-personal/api_key";
      in {
        sops.secrets.${geminiSecret} = {
          owner = user;
          sopsFile = "${inputs.secrets.outPath}/common.yaml";
        };
        sops.templates."hermes-env" = {
          owner = user;
          mode = "0600";
          content = ''
            GEMINI_API_KEY=${config.sops.placeholder.${geminiSecret}}
          '';
        };

        system.activationScripts.postActivation.text = lib.mkAfter ''
          HERMES_HOME="${userHome}/.hermes"
          DOTFILES_CONFIG="${userHome}/.public-dotfiles/hermes/config.kanagawa.yaml"
          WIKI_SOUL="${userHome}/Projects/personal/amgmt/agents/SOUL.md"

          install -d -m 700 -o ${user} -g staff "$HERMES_HOME"
          if [ -f "$DOTFILES_CONFIG" ]; then
            install -m 600 -o ${user} -g staff "$DOTFILES_CONFIG" "$HERMES_HOME/config.yaml"
          fi
          ln -sf ${config.sops.templates."hermes-env".path} "$HERMES_HOME/.env"
          if [ -f "$WIKI_SOUL" ]; then
            ln -sf "$WIKI_SOUL" "$HERMES_HOME/SOUL.md"
          fi
          chown -h ${user}:staff "$HERMES_HOME/.env" "$HERMES_HOME/SOUL.md" 2>/dev/null || true
        '';
      }
      else {
        # ── Usuario dedicado ──────────────────────────────────────────────────
        users.groups.hermes = {};
        users.users.hermes = {
          isSystemUser = true;
          group = "hermes";
          home = "/opt/hermes";
          createHome = true;
          shell = pkgs.bash;
          # linger: el user manager de hermes arranca al boot sin sesión interactiva,
          # lo que permite que el Quadlet arranque hermes.service desde systemd --user.
          linger = true;
          # Rangos sub-UID/GID para Podman rootless (uid 10000 dentro del contenedor)
          subUidRanges = [
            {
              startUid = 100000;
              count = 65536;
            }
          ];
          subGidRanges = [
            {
              startGid = 100000;
              count = 65536;
            }
          ];
        };

        # ── Podman rootless ───────────────────────────────────────────────────
        # Sin dockerCompat ni dockerSocket: hermes no necesita emulación Docker.
        virtualisation.containers.enable = true;
        virtualisation.podman = {
          enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };

        # ── Directorios de configuración ──────────────────────────────────────
        # Los archivos sensibles (dashboard.env, auth.json, etc.) los crea el
        # usuario durante el setup; esta activación solo crea las rutas vacías.
        system.activationScripts.hermes-setup = lib.stringAfter ["users"] ''
          install -d -m 700 -o hermes -g hermes /opt/hermes/.config/hermes
          install -d -m 700 -o hermes -g hermes /opt/hermes/.config/obsidian
          install -d -m 700 -o hermes -g hermes /opt/hermes/.config/containers/systemd

          # agent-wiki: clonar o actualizar el vault compartido
          # El vault es el mismo repo que usan los demás agentes (ZeroClaw, Claude, Codex).
          WIKI_DIR="/opt/hermes/vault"
          WIKI_REPO="git@github.com:themakunga/agent-wiki.git"
          if [ ! -d "$WIKI_DIR/.git" ]; then
            echo "=> Clonando agent-wiki para hermes..."
            /run/wrappers/bin/sudo -H -u hermes env HOME=/opt/hermes \
              ${pkgs.git}/bin/git clone "$WIKI_REPO" "$WIKI_DIR" 2>/dev/null || \
              install -d -m 700 -o hermes -g hermes "$WIKI_DIR"
          else
            /run/wrappers/bin/sudo -H -u hermes env HOME=/opt/hermes \
              ${pkgs.git}/bin/git -C "$WIKI_DIR" pull origin main 2>/dev/null || true
          fi
        '';
      };
  };
}
