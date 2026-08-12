# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: container.nix
# Path: ./modules/applications/container.nix
# Description: Módulo de desarrollo y contenedores
# =====================
{
  flake.developmentModules.containers = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf mkMerge optional optionals optionalString;
    cfg = config.my.development.containers;
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    user = config.system.primaryUser or "nicolas";
  in {
    options.my.development.containers = {
      enable = mkEnableOption "Container and Cloud Native development toolkit";

      runtime = mkOption {
        type = types.enum ["docker" "colima" "podman" "rancher" "none"];
        default = "colima";
        description = "Motor de contenedores a utilizar por defecto.";
      };

      kubernetes = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar utilidades de Kubernetes (kubectl, helm, k9s, kubectx, kustomize).";
      };

      argocd = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar ArgoCD CLI.";
      };

      useDotfiles = mkOption {
        type = types.bool;
        default = true;
        description = "Mapear configuraciones públicas (ej. ~/.kube/config base) desde public-dotfiles";
      };

      useSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Cargar variables de entorno sencillas desde SOPS";
      };

      # 👇 NUEVA OPCIÓN PARA MANEJO EXPERTO DE KUBECONFIGS 👇
      kubeconfigs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Lista de llaves SOPS (ej. 'kubernetes/cluster_dev') que se descifrarán y concatenarán en la variable KUBECONFIG.";
      };
    };

    config = mkIf cfg.enable (mkMerge [
      {
        environment.systemPackages = with pkgs;
          [
            lazydocker
          ]
          ++ optionals (cfg.runtime == "docker") [docker-client docker-compose docker-credential-helpers]
          ++ optionals (cfg.runtime == "colima") [colima docker-client docker-compose docker-credential-helpers]
          ++ optionals (cfg.runtime == "podman") [podman podman-compose]
          ++ optionals cfg.kubernetes [
            kubectl
            kubernetes-helm
            kubectx
            kustomize
            k9s
          ]
          ++ optional cfg.argocd argocd;

        # Declaramos los secretos de SOPS para cada Kubeconfig de la lista
        sops.secrets =
          builtins.listToAttrs (builtins.map (k: {
              name = k;
              value = {owner = user;};
            })
            cfg.kubeconfigs)
          # Agregamos el archivo env por defecto si está habilitado
          // (
            if cfg.useSecrets
            then {"development/containers/env" = {owner = user;};}
            else {}
          );

        environment.interactiveShellInit = ''
          ${optionalString cfg.kubernetes ''
            # Alias de productividad para K8s
            alias k="kubectl"
            alias kx="kubectx"
            alias kn="kubens"
          ''}

          ${optionalString cfg.useSecrets ''
            # Carga de variables entorno simples
            if [ -f "${config.sops.secrets."development/containers/env".path}" ]; then
              source "${config.sops.secrets."development/containers/env".path}"
            fi
          ''}

          ${optionalString (builtins.length cfg.kubeconfigs > 0) ''
            # Inyección de Kubeconfigs Seguros (Descifrados dinámicamente)
            export KUBECONFIG="${builtins.concatStringsSep ":" (builtins.map (k: config.sops.secrets.${k}.path) cfg.kubeconfigs)}"
          ''}
        '';

        my.dotfiles.packages = mkIf cfg.useDotfiles [
          {
            name = "containers";
            isConfig = false;
          }
        ];
      }

      # ==========================================
      # 🍎 OPTIMIZACIONES ESPECÍFICAS PARA MACOS
      # ==========================================
      (mkIf isDarwin {
        homebrew.casks =
          optional (cfg.runtime == "docker") "docker"
          ++ optional (cfg.runtime == "rancher") "rancher"
          ++ optional cfg.kubernetes "openlens";

        environment.variables = mkIf (cfg.runtime == "colima") {
          DOCKER_HOST = "unix:///Users/${user}/.colima/default/docker.sock";
        };

        launchd.user.agents.colima = mkIf (cfg.runtime == "colima") {
          serviceConfig = {
            ProgramArguments = [
              "${pkgs.colima}/bin/colima"
              "start"
              "--vm-type=qemu"
              "--mount-type=9p"
              "--cpu=4"
              "--memory=8"
            ];
            RunAtLoad = true;
            KeepAlive = true;
            StandardErrorPath = "/tmp/colima.err";
            StandardOutPath = "/tmp/colima.out";
          };
        };
      })
    ]);
  };
}
