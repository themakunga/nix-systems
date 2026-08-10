# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.containers
# =========================================================
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
        description = "Cargar tokens y variables sensibles (ej. KUBECONFIG secrets) desde SOPS";
      };
    };

    config = mkIf cfg.enable (mkMerge [
      {
        environment = {
          systemPackages = with pkgs;
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

          interactiveShellInit = ''
            ${optionalString cfg.kubernetes ''
              # Alias de productividad para K8s
              alias k="kubectl"
              alias kx="kubectx"
              alias kn="kubens"
            ''}

            ${optionalString cfg.useSecrets ''
              # Carga de secretos K8s/Docker si están habilitados
              if [ -f "${config.sops.secrets."development/containers/env".path}" ]; then
                source "${config.sops.secrets."development/containers/env".path}"
              fi
            ''}
          '';
        };

        my.dotfiles.packages = mkIf cfg.useDotfiles [
          {
            name = "containers";
            isConfig = false;
          }
        ];

        sops.secrets."development/containers/env" = mkIf cfg.useSecrets {};
      }

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
            RunAtLogin = true;
            KeepAlive = true;
            StandardErrorPath = "/tmp/colima.err";
            StandardOutPath = "/tmp/colima.out";
          };
        };
      })
    ]);
  };
}
