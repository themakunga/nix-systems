# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo: applicationModules.samba-share
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.samba-share = {lib, ...}: {
    options.my.services.samba-share = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "nicolas";
        description = "Admin server username";
      };
    };

    imports = [
      (mkAppModule "samba-share" "Samba Server to share files" {
        meta = _: {
          level = "system";
          packages = [];
        };
        sysConfig = {config, ...}: let
          cfg = config.my.services.samba-share;
        in {
          services.samba = {
            enable = true;
            openFirewall = true;
            settings = {
              global = {
                "workgroup" = "WORKGROUP";
                "security" = "user";
              };
              "Motherbase_Files" = {
                "path" = "/home/${cfg.user}/Shared";
                "browseable" = "yes";
                "read only" = "no";
                "guest ok" = "no";
                "valid users" = cfg.user;
              };
            };
          };
          services.samba-wsdd = {
            enable = true;
            openFirewall = true;
          };
          systemd.tmpfiles.rules = [
            "d /home/${cfg.user}/Shared 0755 ${cfg.user} users -"
          ];
        };
      })
    ];
  };
}
