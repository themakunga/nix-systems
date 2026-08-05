# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
#git add modules/modules/common/apps.nix =========================================================
# Módulo de Aplicaciones de la Infraestructura
# Archivo: modules/modules/common/apps.nix
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

    # Comprobamos de forma pura si la opción homebrew existe en el sistema (solo en darwin)
    isDarwin = options?homebrew;
  in {
    options.my.apps = mkOption {
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
      description = "Colección de aplicaciones configuradas.";
    };

    config = let
      activeApps = filterAttrs (_: g: g.enable) cfg;
      sysApps = filterAttrs (_: g: g.level == "system") activeApps;

      allBrews = flatten (mapAttrsToList (_: g: g.brews) activeApps);
      allCasks = flatten (mapAttrsToList (_: g: g.casks) activeApps);
    in
      {
        environment.systemPackages = flatten (mapAttrsToList (_: g: g.packages) sysApps);
      }
      # Si la opción 'homebrew' existe en el sistema (Darwin), inyectamos el bloque sin tocar pkgs
      // (optionalAttrs isDarwin {
        homebrew = {
          brews = allBrews;
          casks = allCasks;
        };
      });
  };
}
