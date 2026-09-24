# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo: applicationModules.hermes
# Hermes AI Agent con Obsidian oficial en Podman rootless.
# Cuenta dedicada /opt/hermes, Quadlet de usuario, sin grupos administrativos.
{self, ...}: {
  flake.applicationModules.hermes = self.lib.mkAppModule "hermes" "Hermes AI Agent con Obsidian en Podman rootless" {
    meta = {level = "system";};

    sysConfig = {
      pkgs,
      lib,
      ...
    }: {
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
        install -d -m 700 -o hermes -g hermes /opt/hermes/vault
      '';
    };
  };
}
