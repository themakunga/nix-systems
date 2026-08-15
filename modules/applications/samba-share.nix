# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModule.samba-share = mkAppModule "samba-share" "Samba Server
    to share files" {
    meta = {
      level = "system";
      packages = [];
    };
    sysConfig = {
      config,
      lib,
      ...
    }: let
      cfg = config.my.services.samba-share;
      inherit (lib) mkIf types mkOption;
    in {
      options.my.service.samba-share = {
        user = mkOption {
          type = types.str;
          default = "nicolas";
          description = "Admin server username";
        };
      };

      config = mkIf config.my.services.samba-share.enable {
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
              "readonly" = "no";
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
    };
  };
}
