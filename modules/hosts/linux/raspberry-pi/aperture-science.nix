# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Host: aperture-science (RPi 5 AI Node)
# =========================================================
{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    disko
    sops-nix
    nixos-hardware
    ;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.aperture-science = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "aperture-science";
    };

    modules =
      [
        nixos-hardware.nixosModules.raspberry-pi-5
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
      ]
      ++ (mkBundle {
        commonModules = [
          "dotfiles"
          "apps"
          "arch.nixos.rpi"
          "authorized-keys"
          "host-secrets"
          "network"
          "settings"
          "userProfiles"
          "wallpaper"
          "weather"
        ];
        nixosModules = [
          "base-machine"
          "nix-anywhere" # Fundamental para inyectar llaves SSH durante el despliegue
          "hyprland-desktop"
          "wifi"
        ];
        rpiModules = [
          "common"
          "disko-nvme" # Utiliza tu módulo que formatea automáticamente /dev/nvme0n1
          "hardware-rpi5"
          "performance"
        ];
        userModules = [
          "glados" # Service account — zeroclaw + ollama, home /opt/glados
          "wheatley" # Autologin Hyprland, home /opt/wheatley
          "nicolas" # Administrador SSH — sudo, sin home, password expirado al primer login
        ];
        applicationModules = [
          "tailscale.core"
          "ollama"
        ];
      })
      ++ [
        ({
          pkgs,
          lib,
          ...
        }: {
          # Declaramos primaryUser localmente para satisfacer al módulo nix-anywhere
          options.my.primaryUser.username = lib.mkOption {
            type = lib.types.str;
            default = "nicolas";
          };

          config = {
            my = {
              primaryUser.username = "nicolas";
              dotfiles.enable = true;
              wallpaper = {
                path = "${self}/media/wp/aperture-science.jpg";
                enable = true;
                fileName = "aperture-science.jpg";
              };
              weather = {
                enable = true;
                location = "Quebrada de Macul, Chile";
                units = "c";
                forecast = ["d" "w"];
              };
              nix-anywhere.enable = true;

              # Si ya configuraste sops para este host, descomenta la siguiente línea:
              # hostSecrets.file = "${secrets.outPath}/hosts/aperture-science.yaml";

              base-machine = {
                enable = true;
                bootMode = "rpi";
              };

              apps.tailscale-core.enable = true;

              # Ollama: servidor LLM local (CPU-only en RPi5, 8GB RAM)
              # API REST en :11434 — accesible por Tailscale y red local
              ollama.enable = true;

              # Escritorio Wayland liviano: Hyprland con autologin como wheatley
              hyprland-desktop = {
                enable = true;
                user = "wheatley";
                vnc = {
                  enable = true;
                  # Escucha en todas las interfaces: accesible desde red local y Tailscale.
                  address = "0.0.0.0";
                  port = 5900;
                };
              };

              # SSH keys declaradas directamente — independiente de public_keys.json
              # Asignadas a root (solo llave, PermitRootLogin = prohibit-password)
              # y a nicolas (llave primaria + password expirado al primer login)
              authorizedKeys = {
                enable = true;
                assignTo = ["root" "nicolas"];
                keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHjzdPBqDPXdyApkurnNyFKUQFIw+4/jX68e4nZzvUu3 nmartinezv@icloud.com"
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfrS5Ps9OxiIKgMJo718RbJ7Lwaijwt3g0lEBb8mhCt nicolas@Nicolass-MacBook-Pro.local"
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE2r+riw/cQSooaLGrva8+2r6MHfji8WFyntj5ftvTiR work@outer-heaven.local"
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxEzgi1BeML32LyZA4EkIfxJrd44QetW6k5iqibsXzJ admin@aperture-sciece.local"
                ];
              };
            };

            # GLaDOS: service account para IA local (zeroclaw).
            # El módulo glados la define sin shell interactiva — override necesario
            # para que zeroclaw pueda ejecutar subprocesos de shell correctamente.
            users.users.glados = {
              shell = lib.mkForce pkgs.bash;
              extraGroups = lib.mkForce ["glados" "docker"];
              createHome = lib.mkForce true;
              # zeroclaw: asistente LLM autónomo — solo accesible para glados.
              # Instalado en /etc/profiles/per-user/glados/ (no en PATH del sistema).
              packages = [pkgs.unstable.zeroclaw];
            };

            # mDNS: Avahi permite resolver aperture-science.local en la red local.
            services.avahi = {
              enable = true;
              nssmdns4 = true; # resolución .local vía NSS
              publish = {
                enable = true;
                addresses = true; # anuncia IP en la red
                domain = true;
              };
            };

            # ── ZeroClaw: AI agent gateway ─────────────────────────────────────
            # Corre como glados, expone HTTP en :42617 (dashboard + WebSocket).
            # Config: /opt/glados/.zeroclaw/config.toml (desplegada via stow desde agent/).
            # Auth Codex: ver instrucciones al pie de este archivo.
            systemd.services.zeroclaw = {
              description = "ZeroClaw AI Agent Gateway";
              documentation = ["https://github.com/zeroclaw-labs/zeroclaw"];
              after = ["network-online.target"];
              wants = ["network-online.target"];
              wantedBy = ["multi-user.target"];
              serviceConfig = {
                Type = "simple";
                User = "glados";
                Group = "glados";
                WorkingDirectory = "/opt/glados";
                Environment = [
                  "HOME=/opt/glados"
                  "XDG_CONFIG_HOME=/opt/glados/.config"
                ];
                ExecStart = "${pkgs.unstable.zeroclaw}/bin/zeroclaw service start";
                Restart = "on-failure";
                RestartSec = "10s";
                NoNewPrivileges = true;
                PrivateTmp = true;
              };
            };

            # ── GLaDOS agent dotfiles: stow agent/ → /opt/glados/.zeroclaw/ ──
            # Clona public-dotfiles y aplica stow de la carpeta 'agent' al directorio
            # de configuración de zeroclaw (~/.zeroclaw/ para el usuario glados).
            system.activationScripts."glados-agent-dotfiles" = {
              text = ''
                DOTFILES_DIR="/opt/glados/.public-dotfiles"
                REPO_URL="https://github.com/themakunga/public-dotfiles.git"
                ZEROCLAW_DIR="/opt/glados/.zeroclaw"

                echo "=> Sincronizando configuración del agente para GLaDOS..."

                mkdir -p "$ZEROCLAW_DIR"
                chown glados:glados "$ZEROCLAW_DIR" 2>/dev/null || true

                if [ ! -d "$DOTFILES_DIR/.git" ]; then
                  echo "Clonando public-dotfiles para glados..."
                  /run/wrappers/bin/sudo -H -u glados env HOME=/opt/glados \
                    ${pkgs.git}/bin/git clone "$REPO_URL" "$DOTFILES_DIR" || true
                else
                  /run/wrappers/bin/sudo -H -u glados env HOME=/opt/glados \
                    ${pkgs.git}/bin/git -C "$DOTFILES_DIR" pull origin main 2>/dev/null || true
                fi

                if [ -d "$DOTFILES_DIR/agent" ]; then
                  echo "Desplegando configuración agent/ → $ZEROCLAW_DIR..."
                  /run/wrappers/bin/sudo -H -u glados env HOME=/opt/glados \
                    ${pkgs.stow}/bin/stow -t "$ZEROCLAW_DIR" -d "$DOTFILES_DIR" --adopt agent
                else
                  echo "Advertencia: carpeta 'agent' no encontrada en $DOTFILES_DIR"
                fi
              '';
            };

            # Firewall: puerto del gateway zeroclaw (42617) accesible desde la red local
            networking.firewall.allowedTCPPorts = [42617];

            # DNS: deshabilitar accept-dns de Tailscale para usar resolvers del sistema.
            # El resolver de Tailscale (100.102.172.33) no responde a queries públicas.
            # Con accept-dns=false, resolvconf usa 1.1.1.1 + 8.8.8.8 + gateway local.
            services.tailscale.extraUpFlags = ["--accept-dns=false"];
            networking.nameservers = ["1.1.1.1" "8.8.8.8"];

            # wheel sin contraseña — necesario para nixos-rebuild remoto
            security.sudo.wheelNeedsPassword = false;

            # SSH sin sesión logind: evita que pam_systemd bloquee auth SSH
            # cuando D-Bus está ocupado (ej: greetd/Hyprland en crash loop).
            # Sin esto, cada conexión SSH espera que logind registre la sesión
            # vía D-Bus → timeout → SSH inaccesible aunque el sistema esté vivo.
            security.pam.services.sshd.startSession = lib.mkForce false;
          };
        })
      ];
  };
}
