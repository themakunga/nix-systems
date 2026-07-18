# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{inputs, ...}: let
  inherit (inputs) sops-nix secrets;
  commonSopsFile = "${secrets.outPath}/common.yaml";
in {
  flake.commonModules = {
    sops = {
      gpg = {
        pkgs,
        lib,
        ...
      }: let
        inherit (lib) mkEnableOption mkOption types mkIf concatMapStringsSep;
      in {
        home-manager.sharedModules = [
          (
            {
              config,
              lib,
              ...
            }: let
              cfg = config.programs.sops.gpg;
              inherit (lib.hm.dag) entryAfter;
            in {
              options.programs.sops.gpg = {
                enable = mkEnableOption "Declarative GPG key importer";
                keys = mkOption {
                  default = [];
                  type = types.listOf (
                    types.submodule {
                      options = {
                        name = mkOption {type = types.str;};
                        publicKey = mkOption {type = types.str;};
                        privateKey = mkOption {type = types.str;};
                      };
                    }
                  );
                };
              };
              config = mkIf cfg.enable {
                home.activation.importSopsGpg = entryAfter ["writeBoundary"] (
                  concatMapStringsSep "\n" (key: ''
                    if [ -f "${key.publicKey}" ]; then
                      ${pkgs.gnupg}/bin/gpg --import "${key.publicKey}"
                    fi
                    if [ -f "${key.privateKey}" ]; then
                      ${pkgs.gnupg}/bin/gpg --import "${key.privateKey}"
                    fi
                  '')
                  cfg.keys
                );
              };
            }
          )
        ];
      };
    };

    home-gpg-profiles = {
      config,
      lib,
      osConfig ? {},
      ...
    }: let
      inherit (lib) mkEnableOption mkOption types mkIf;
      cfg = config.my.gpgProfiles;
      hostName = osConfig.networking.hostName or "default";
      hostSopsFile = "${secrets.outPath}/hosts/${hostName}.yaml";
    in {
      options.my.gpgProfiles = {
        enable = mkEnableOption "Gestor automático de llaves GPG por host";
        profiles = mkOption {
          type = types.listOf types.str;
          default = [];
        };
      };

      config = mkIf cfg.enable {
        sops.secrets = builtins.listToAttrs (
          builtins.concatMap (name: [
            {
              name = "profiles/${name}/gpg/public_key";
              value = {sopsFile = hostSopsFile;};
            }
            {
              name = "profiles/${name}/gpg/private_key";
              value = {sopsFile = hostSopsFile;};
            }
          ])
          cfg.profiles
        );

        programs.sops.gpg = {
          enable = true;
          keys =
            builtins.map (name: {
              name = "${name}-key";
              publicKey = config.sops.secrets."profiles/${name}/gpg/public_key".path;
              privateKey = config.sops.secrets."profiles/${name}/gpg/private_key".path;
            })
            cfg.profiles;
        };
      };
    };

    host-secrets = {
      lib,
      config,
      pkgs,
      ...
    }: let
      inherit (lib) mkOption types mkDefault mapAttrs;
      cfg = config.my.hostSecrets;
      user = config.system.primaryUser or "nicolas";
      userHome =
        if pkgs.stdenv.isDarwin
        then "/Users/${user}"
        else "/home/${user}";
    in {
      options.my.hostSecrets = {
        file = mkOption {
          type = types.str;
          default = commonSopsFile;
        };
        userSecrets = mkOption {
          type = types.attrsOf types.attrs;
          default = {};
        };
      };

      config = {
        sops = {
          defaultSopsFile = mkDefault cfg.file;
          validateSopsFiles = false;
          age.sshKeyPaths = [
            "/etc/ssh/ssh_host_ed25519_key"
            "${userHome}/.ssh/id_ed25519"
          ];
          secrets = mapAttrs (_name: value:
            value
            // {
              owner = mkDefault user;
            })
          cfg.userSecrets;
        };
      };
    };

    home-secrets = {
      lib,
      config,
      ...
    }: let
      inherit (config.home) homeDirectory;
    in {
      imports = [sops-nix.homeManagerModules.sops];

      sops = {
        defaultSopsFile = lib.mkDefault commonSopsFile;

        age = {
          sshKeyPaths = ["${homeDirectory}/.ssh/id_ed25519"];
          generateKey = false;
        };

        secrets = {
          "wifi/AMANDA".sopsFile = commonSopsFile;
          "wifi/42DEVS_5G".sopsFile = commonSopsFile;
          "wifi/42DEVS".sopsFile = commonSopsFile;
          "tailscale/auth_token".sopsFile = commonSopsFile;
        };
      };
    };

    git-identity = {
      config,
      lib,
      ...
    }: let
      inherit (lib) mkEnableOption mkOption types mkIf mkMerge optionalAttrs mapAttrsToList;
      cfg = config.programs.git-identity;
    in {
      options.programs.git-identity = {
        enable = mkEnableOption "Gestor de identidad de Git parametrizado";
        global = {
          enable = mkEnableOption "Identidad global por defecto";
          realName = mkOption {type = types.str;};
          email = mkOption {type = types.str;};
          gpg = {
            enable = mkEnableOption "Firmado global con GPG";
            keyId = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
          };
          ssh = {
            enableAuth = mkEnableOption "Auth SSH global";
            privateKey = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
          };
        };
        workspaces = mkOption {
          default = {};
          type = types.attrsOf (
            types.submodule {
              options = {
                directory = mkOption {type = types.str;};
                realName = mkOption {type = types.str;};
                email = mkOption {type = types.str;};
                gpg = {
                  enable = mkEnableOption "Firmado GPG para este workspace";
                  keyId = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };
                };
                ssh = {
                  enableAuth = mkEnableOption "Auth SSH para este workspace";
                  privateKey = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };
                };
              };
            }
          );
        };
      };

      config = mkIf cfg.enable {
        programs.git = {
          enable = true;
          userName = mkIf cfg.global.enable cfg.global.realName;
          userEmail = mkIf cfg.global.enable cfg.global.email;
          signing = mkIf (cfg.global.enable && cfg.global.gpg.enable) {
            key = cfg.global.gpg.keyId;
            signByDefault = true;
          };
          settings = mkMerge [
            (mkIf (cfg.global.enable && cfg.global.ssh.enableAuth) {
              core.sshCommand = "ssh -i ${cfg.global.ssh.privateKey} -o IdentitiesOnly=yes";
            })
          ];
          includes =
            mapAttrsToList (_name: ws: {
              condition = "gitdir:${ws.directory}/";
              contents = {
                user =
                  {
                    name = ws.realName;
                    inherit (ws) email;
                  }
                  // optionalAttrs ws.gpg.enable {
                    signingkey = ws.gpg.keyId;
                  };
                commit = optionalAttrs ws.gpg.enable {gpgsign = true;};
                core = optionalAttrs ws.ssh.enableAuth {
                  sshCommand = "ssh -i ${ws.ssh.privateKey} -o IdentitiesOnly=yes";
                };
              };
            })
            cfg.workspaces;
        };
      };
    };
  };
}
