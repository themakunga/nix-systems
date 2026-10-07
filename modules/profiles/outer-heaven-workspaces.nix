# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# outer-heaven-workspaces — identidades Git por cliente
#
# Cada entrada genera automáticamente:
#   ~/Projects/<name>/.gitconfig     ← user + gpg + core.sshCommand
#   ~/Projects/<name>/.ssh/config    ← IdentityFile específico
#   entrada includeIf en ~/.gitconfig.nix-managed
#
# Para agregar un cliente nuevo: añadir un bloque aquí y rebuild.
# Las llaves SSH viven en ~/.ssh/ (secret-dotfiles).
# Los fingerprints GPG son públicos — no necesitan SOPS.
# =========================================================
{
  flake.profileModules.outer-heaven-workspaces = _: {
    programs.git-identity = {
      enable = true;
      projectRoot = "~/Projects";

      # ── Default global: ThoughtWorks ──────────────────────────────
      # Cubre cualquier repo que no esté bajo ~/Projects/<workspace>/
      global = {
        enable = true;
        realName = "Nicolas Villarroel";
        email = "nicolas.villarroel@thoughtworks.com";
        gpg = {
          enable = true;
          keyId = "C77C9D58992A3B0E"; # Nicolas Villarroel <nicolas.villarroel@thoughtworks.com>
        };
        ssh = {
          enable = true;
          privateKey = "~/.ssh/id_ed25519_thoughtworks";
        };
      };

      workspaces = {
        # ── Personal ─────────────────────────────────────────────────
        personal = {
          directory = "~/Projects/personal/**";
          realName = "Nicolas Villarroel Martinez";
          email = "nmartinezv@icloud.com";
          gpg = {
            enable = true;
            keyId = "7F8D31D0087476D2"; # Nicolas Villarroel <nmartinezv@icloud.com>
          };
          ssh = {
            enable = true;
            privateKey = "~/.ssh/id_ed25519";
          };
        };

        # ── LATAM Airlines ────────────────────────────────────────────
        latam = {
          directory = "~/Projects/latam/**";
          realName = "Villarroel, Nicolas";
          email = "nicolasvillarroel.thoughtworks@latam.com";
          gpg = {
            enable = true;
            keyId = "83B0E6D44082FE2D"; # Nicolas Villarroel, (THOUGHTWORKS) <nicolasvillarroel.thoughtworks@latam.com>
          };
          ssh = {
            enable = true;
            privateKey = "~/.ssh/gitlab-latamairlines";
          };
        };

        # ── Grainger ─────────────────────────────────────────────────
        Grainger = {
          directory = "~/Projects/Grainger/**";
          realName = "Nicolas Villarroel Martinez";
          email = "nicolas.villarroel1@grainger.com";
          gpg = {
            enable = true;
            keyId = "FC1A168A96528672"; # Nicolas Villarroel Martinez (Grainger) <nicolas.villarroel1@grainger.com>
          };
          ssh = {
            enable = true;
            privateKey = "~/.ssh/id_ed25519_grangier";
          };
        };

        # ── 42Devs ────────────────────────────────────────────────────
        "42devs" = {
          directory = "~/Projects/42devs/**";
          realName = "Nicolas Villarroel Martinez";
          email = "nicolas@42devs.cl";
          gpg = {
            enable = true;
            keyId = "CB296A9D652AA5B7"; # Elron <elron@rivendell.local>
          };
          ssh = {
            enable = true;
            privateKey = "~/.ssh/id_ed25519_42devs";
          };
        };

        # ── outcast_sur hereda el default ThoughtWorks ────────────────
        # (no entry needed — ~/Projects/outcast_sur/** uses global identity)
      };
    };
  };
}
