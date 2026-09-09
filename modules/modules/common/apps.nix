# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Módulo de Aplicaciones de la Infraestructura
# Archivo: modules/modules/common/apps.nix
#
# Dos formas de declarar software en un host o profile:
#
#   1. Listas directas (sin enable) — para paquetes simples:
#        my.packages  = [ pkgs.btop pkgs.stow ];
#        my.casks     = [ "iterm2" "wezterm" ];
#        my.masApps   = { "Magnet" = 441258766; };
#        my.brews     = [ "xcode-build-server" ];
#
#   2. Apps nombradas (con enable) — para apps con configuración propia
#      (servicios, dotfiles, credenciales, etc.):
#        my.apps.tailscale-core.enable = true;
#        my.apps.neovim.enable = true;
#
# Las listas directas de múltiples módulos se concatenan automáticamente.
# =========================================================
_: {
  flake.commonModules.apps = {
    config,
    lib,
    options,
    ...
  }: let
    inherit (lib) mkOption types filterAttrs mapAttrsToList flatten optionalAttrs;
    cfg = config.my.apps;

    # Comprobamos de forma pura si la opción homebrew existe (solo en Darwin)
    isDarwin = options ? homebrew;

    # Apps nombradas activas (enable = true)
    activeApps = filterAttrs (_: g: g.enable) cfg;

    # Paquetes de apps nombradas que van a nivel sistema
    sysApps = filterAttrs (_: g: g.level == "system") activeApps;

    # Homebrew: recolectamos de las apps nombradas activas
    appsBrews = flatten (mapAttrsToList (_: g: g.brews) activeApps);
    appsCasks = flatten (mapAttrsToList (_: g: g.casks) activeApps);
    appsMasApps = builtins.foldl' (acc: g: acc // g.masApps) {} (builtins.attrValues activeApps);
  in {
    options.my = {
      # ------------------------------------------------------------------
      # Grupo 1 — Listas directas: sin enable, sin wrappers
      # ------------------------------------------------------------------
      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Paquetes de sistema directos (nixpkgs/nix-darwin). Se concatenan entre hosts y profiles.";
      };

      casks = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Casks de Homebrew (GUI apps). Se concatenan entre hosts y profiles.";
      };

      masApps = mkOption {
        type = types.attrsOf types.int;
        default = {};
        description = "Apps de la Mac App Store. Se fusionan entre hosts y profiles.";
      };

      brews = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Fórmulas CLI de Homebrew. Se concatenan entre hosts y profiles.";
      };

      # ------------------------------------------------------------------
      # Grupo 2 — Apps nombradas con configuración propia (enable requerido)
      # ------------------------------------------------------------------
      apps = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            enable = lib.mkEnableOption "Habilitar esta app/perfil";

            level = mkOption {
              type = types.enum ["system" "user"];
              default = "user";
              description = "Nivel de instalación de los paquetes.";
            };

            targetUser = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Usuario objetivo opcional para el contexto del módulo.";
            };

            packages = mkOption {
              type = types.listOf types.package;
              default = [];
              description = "Paquetes nativos de Nix.";
            };

            casks = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Casks de Homebrew (GUI).";
            };

            brews = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "Fórmulas CLI de Homebrew.";
            };

            masApps = mkOption {
              type = types.attrsOf types.int;
              default = {};
              description = "Aplicaciones de la Mac App Store.";
            };
          };
        });
        default = {};
        description = "Colección de apps con configuración propia (servicios, dotfiles, etc.).";
      };
    };

    config =
      {
        # Paquetes directos + paquetes de apps nombradas a nivel sistema
        environment.systemPackages =
          config.my.packages
          ++ flatten (mapAttrsToList (_: g: g.packages) sysApps);
      }
      # Homebrew solo en Darwin
      // (optionalAttrs isDarwin {
        homebrew = {
          brews = appsBrews ++ config.my.brews;
          casks = appsCasks ++ config.my.casks;
          masApps = appsMasApps // config.my.masApps;
        };
      });
  };
}
