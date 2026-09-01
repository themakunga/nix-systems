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
        ];
        nixosModules = [
          "base-machine"
          "nix-anywhere" # Fundamental para inyectar llaves SSH durante el despliegue
          "terminal-kiosk"
          "wifi"
        ];
        rpiModules = [
          "common"
          "disko-nvme" # Utiliza tu módulo que formatea automáticamente /dev/nvme0n1
          "hardware-rpi5"
          "performance"
        ];
        userModules = [
          "glados" # Importa el módulo y la jaula de GLaDOS
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
            default = "admin";
          };

          config = {
            my = {
              primaryUser.username = "admin";

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

              # Kiosk Wayland: GLaDOS abre foot+zellij a pantalla completa al arrancar
              terminal-kiosk = {
                enable = true;
                user = "glados";
                multiplexer = "zellij";
              };

              # Usuario administrador
              userProfiles.admin = {
                username = "admin";
                fullName = "Aperture Admin";
                description = "System Administrator";
                isSystem = false;
                isAdmin = true;
                isNetworkManager = true;
                extraGroups = ["docker"];
              };

              # SSH keys declaradas directamente — independiente de public_keys.json
              authorizedKeys = {
                enable = true;
                assignTo = ["admin" "root"];
                keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHjzdPBqDPXdyApkurnNyFKUQFIw+4/jX68e4nZzvUu3 nmartinezv@icloud.com"
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfrS5Ps9OxiIKgMJo718RbJ7Lwaijwt3g0lEBb8mhCt nicolas@Nicolass-MacBook-Pro.local"
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE2r+riw/cQSooaLGrva8+2r6MHfji8WFyntj5ftvTiR work@outer-heaven.local"
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINxEzgi1BeML32LyZA4EkIfxJrd44QetW6k5iqibsXzJ admin@aperture-sciece.local"
                ];
              };
            };

            # GLaDOS como usuario kiosk: el módulo glados la define como service account
            # sin shell interactiva ni grupos gráficos — overrides necesarios para Wayland
            users.users.glados = {
              shell = lib.mkForce pkgs.bash;
              extraGroups = lib.mkForce ["glados" "docker" "video" "input" "render" "audio"];
              createHome = lib.mkForce true;
              # zeroclaw: asistente LLM autónomo — solo accesible para glados.
              # Instalado en /etc/profiles/per-user/glados/ (no en PATH del sistema).
              packages = [pkgs.unstable.zeroclaw];
            };

            # DNS: deshabilitar accept-dns de Tailscale para usar resolvers del sistema.
            # El resolver de Tailscale (100.102.172.33) no responde a queries públicas.
            # Con accept-dns=false, resolvconf usa 1.1.1.1 + 8.8.8.8 + gateway local.
            services.tailscale.extraUpFlags = ["--accept-dns=false"];
            networking.nameservers = ["1.1.1.1" "8.8.8.8"];

            # wheel sin contraseña — necesario para nixos-rebuild remoto
            security.sudo.wheelNeedsPassword = false;
          };
        })
      ];
  };
}
