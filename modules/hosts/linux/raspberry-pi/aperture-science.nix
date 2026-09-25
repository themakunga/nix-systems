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
          "shared-plain"
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
        profileModules = ["terminal-tools"];
        applicationModules = [
          "bat"
          "yazi"
          "zoxide"
          "tailscale.core"
          "ollama"
          "wezterm" # Terminal principal — instala wezterm + stow ~/.wezterm.lua (TokyoNight Storm)
          "neovim" # Editor — instala neovim 0.12 + stow ~/.config/nvim/ desde public-dotfiles
          "hermes" # Hermes AI Agent con Obsidian oficial en Podman rootless (/opt/hermes)
          "remote-touchpad" # iPad como teclado/touchpad via uinput — Safari en :9100
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
              dotfiles = {
                enable = true;
                # wheatley: usuario autologin de Hyprland.
                # Home en /opt/wheatley (convención kiosk/service).
                user = "wheatley";
                home = "/opt/wheatley";
                packages = [
                  {
                    name = "hypr";
                    isConfig = true;
                  } # ~/.config/hypr/ — Hyprland TokyoNight Storm
                  {name = "bash";} # ~/.bashrc — oh-my-posh + fastfetch + aliases
                  {
                    name = "fastfetch";
                    isConfig = true;
                  } # ~/.config/fastfetch/ — logo Aperture
                  {
                    name = "ohmyposh";
                    isConfig = true;
                  } # ~/.config/ohmyposh/config.yaml
                  {
                    name = "wofi";
                    isConfig = true;
                  } # ~/.config/wofi/
                  {
                    name = "waybar";
                    isConfig = true;
                  } # ~/.config/waybar/
                ];
                # nicolas: administrador con escritorio Hyprland independiente.
                # Recibe tooling dev + config de terminal y editor.
                additionalUsers = [
                  {
                    user = "nicolas";
                    home = "/home/nicolas";
                    packages = [
                      {
                        name = "nvim";
                        isConfig = true;
                      } # ~/.config/nvim/
                      {name = "wezterm";} # ~/.wezterm.lua
                      {name = "bash";} # ~/.bashrc
                      {name = "git";} # ~/.gitconfig
                      {
                        name = "fastfetch";
                        isConfig = true;
                      } # ~/.config/fastfetch/
                      {
                        name = "ohmyposh";
                        isConfig = true;
                      } # ~/.config/ohmyposh/
                      {name = "tmux";} # ~/.tmux.conf
                      {name = "zoxide";} # ~/.config/zoxide/
                      {
                        name = "bat";
                        isConfig = true;
                      } # ~/.config/bat/
                      {
                        name = "yazi";
                        isConfig = true;
                      } # ~/.config/yazi/
                    ];
                  }
                ];
              };
              wallpaper = {
                enable = true;
                user = "wheatley"; # home /opt/wheatley — usuario autologin Hyprland
                path = "${self}/media/wp/aperture-science.jpg";
                fileName = "aperture-science.jpg";
              };
              weather = {
                enable = true;
                location = "Quebrada de Macul, Chile";
                units = "c";
                forecast = ["d" "w"];
              };
              nix-anywhere.enable = true;

              # SOPS: descomentar cuando exista hosts/aperture-science.yaml en el repo .secrets.
              # Contiene: wheatley/password (hashedPassword para tuigreet).
              # hostSecrets.file = "${secrets.outPath}/hosts/aperture-science.yaml";
              # hostSecrets.userSecrets = [{ name = "wheatley/password"; owner = "wheatley"; }];

              base-machine = {
                enable = true;
                bootMode = "rpi";
              };

              apps = {
                tailscale-core.enable = true;
                wechat.enable = true;
                hermes.enable = true; # Hermes AI Agent — solo en aperture-science
                remote-touchpad.enable = true; # iPad como teclado/touchpad — solo en aperture-science
                wezterm.enable = true; # Terminal principal con config TokyoNight Storm
                neovim.enable = true; # Editor con LSP, treesitter, toolchain completo
              };

              # Ollama: servidor LLM local (CPU-only en RPi5, 8GB RAM)
              # API REST en :11434 — accesible por Tailscale y red local
              ollama.enable = true;

              # Escritorio Wayland: Hyprland multi-usuario con tuigreet.
              # NOTA: multiUser requiere contraseña en wheatley vía SOPS.
              # Mientras no esté el secrets file, dejar multiUser = false (autologin).
              hyprland-desktop = {
                enable = true;
                user = "wheatley"; # usuario default / autologin cuando multiUser=false
                # Los dotfiles (paquete "hypr") proveen ~/.config/hypr/hyprland.conf
                # vía stow. El módulo gestiona waybar y foot, pero NO hyprland.conf.
                manageConfig = false;
                multiUser = false; # cambiar a true tras configurar SOPS para wheatley
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

            # Paquetes del stack terminal (fastfetch, oh-my-posh, fzf).
            # wezterm y neovim los instalan sus respectivos applicationModules.
            environment.systemPackages = with pkgs; [
              # ── Terminal & prompt ───────────────────────────────────────────
              fastfetch # panel de sistema — config en ~/.config/fastfetch/
              oh-my-posh # prompt para bash (y zsh) — config en ~/.config/ohmyposh/
              fzf # fuzzy finder — integrado en .bashrc

              # ── Lanzador Wayland ────────────────────────────────────────────
              wofi # launcher Wayland (reemplaza rofi) — config en ~/.config/wofi/

              # ── Lenguajes y runtimes de desarrollo ─────────────────────────
              python3 # Python 3.x — scripting, agentes, automatización
              nodejs_22 # Node.js 22 LTS — tooling JS/TS
              go # Go — servicios, CLIs, infraestructura
              terraform # Terraform — IaC para homelab
            ];

            users.users = {
              # GLaDOS: service account para IA local (zeroclaw).
              # El módulo glados la define sin shell interactiva — override necesario
              # para que zeroclaw pueda ejecutar subprocesos de shell correctamente.
              glados = {
                shell = lib.mkForce pkgs.bash;
                extraGroups = lib.mkForce ["glados" "docker"];
                createHome = lib.mkForce true;
                # zeroclaw: asistente LLM autónomo — solo accesible para glados.
                # Instalado en /etc/profiles/per-user/glados/ (no en PATH del sistema).
                packages = [pkgs.unstable.zeroclaw];
                # linger = true: systemd-logind levanta el user manager de glados al
                # boot (sin sesión interactiva), creando /run/user/466 y el D-Bus
                # session bus que zeroclaw necesita para arrancar.
                linger = true;
              };
              # wheatley necesita el grupo uinput para escribir en /dev/uinput
              # (regla udev creada por hardware.uinput.enable en remote-touchpad.nix)
              wheatley.extraGroups = ["uinput"];
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
              after = ["network-online.target" "user@466.service"];
              wants = ["network-online.target" "user@466.service"];
              wantedBy = ["multi-user.target"];
              serviceConfig = {
                Type = "simple";
                User = "glados";
                Group = "glados";
                WorkingDirectory = "/opt/glados";
                Environment = [
                  "HOME=/opt/glados"
                  "XDG_CONFIG_HOME=/opt/glados/.config"
                  # glados uid=466 — linger=true garantiza que /run/user/466 existe
                  # y que el D-Bus session bus está activo antes de arrancar zeroclaw.
                  "XDG_RUNTIME_DIR=/run/user/466"
                  "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/466/bus"
                  # PATH explícito — systemd no hereda el PATH del sistema.
                  # zeroclaw necesita 'sh' para ejecutar herramientas y canales (Telegram).
                  "PATH=/run/current-system/sw/bin:/run/wrappers/bin:/usr/bin:/bin"
                ];
                # 'zeroclaw daemon' lanza el runtime completo (gateway + canales + cron).
                # NO usar 'zeroclaw service start' — ese comando instala/arranca un user
                # service vía D-Bus y no puede correr dentro del propio system service.
                ExecStart = "${pkgs.unstable.zeroclaw}/bin/zeroclaw daemon";
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

            networking = {
              # Firewall: puerto del gateway zeroclaw (42617) accesible desde la red local
              firewall.allowedTCPPorts = [42617];
              # DNS: deshabilitar accept-dns de Tailscale para usar resolvers del sistema.
              # El resolver de Tailscale (100.102.172.33) no responde a queries públicas.
              # Con accept-dns=false, resolvconf usa 1.1.1.1 + 8.8.8.8 + gateway local.
              nameservers = ["1.1.1.1" "8.8.8.8"];
              # IP estática en end0 — evita que DHCP cambie la IP y permite usar
              # aperture-science.local o la IP fija (192.168.5.85) desde el iPad/Mac.
              interfaces.end0 = {
                useDHCP = false;
                ipv4.addresses = [
                  {
                    address = "192.168.5.85";
                    prefixLength = 22;
                  }
                ];
              };
              defaultGateway = "192.168.4.1";
            };
            services.tailscale.extraUpFlags = ["--accept-dns=false"];

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
