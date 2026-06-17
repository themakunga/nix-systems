{inputs, ...}: let
  inherit (inputs) sops-nix secrets;
in {
  flake.commonModules = {
    sops = {
      gpg = {
        pkgs,
        lib,
        ...
      }: let
        inherit
          (lib)
          mkEnableOption
          mkOption
          types
          mkIf
          concatMapStringsSep
          ;
      in {
        home-manager.sharedModules = [
          (
            {config, ...}: let
              cfg = config.programs.sops.gpg;
              inherit (config.lib.home-manager.dag) entryAfter;
            in {
              options.programs.sops.gpg = {
                enable = mkEnableOption "Declarative GPG key importer";
                keys = mkOption {
                  description = "Private and Public GPG Keys";
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
                      echo "[GPG] import public key to host: ${key.name}..."
                      ${pkgs.gnupg}/bin/gpg --import "${key.publicKey}"
                    fi
                    if [ -f "${key.privateKey}" ]; then
                      echo "[GPG] import private key to host: ${key.name}..."
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

      shared-secrets = {config, ...}: let
        inherit (config.home) homeDirectory;
        host = config.networking.hostName or "default";
        commonSopsFile = "${secrets}/common.yaml";
        hostSopsFile = "${secrets}/hosts/${host}.yaml";
      in {
        imports = [sops-nix.homeManagerModules.sops];

        sops = {
          age = {
            sshKeyPath = ["${homeDirectory}/.ssh/id_ed25519"];
            generateKey = false;
          };

          defaultSopsFile =
            if builtins.pathExists hostSopsFile
            then hostSopsFile
            else commonSopsFile;

          secrets = {
            "wifi/AMANDA" = {
              sopsFile = commonSopsFile;
            };
            "wifi/42Dev_5G" = {
              sopsFile = commonSopsFile;
            };
            "wifi/42Devs" = {
              sopsFile = commonSopsFile;
            };
            "tailscale/aut_token" = {
              sopsFile = commonSopsFile;
            };
          };
        };
      };
    };

    git-identity = {
      config,
      lib,
      ...
    }: let
      inherit
        (lib)
        mkEnableOption
        mkOption
        types
        mkIf
        mkMerge
        optionalAttrs
        mapAttrsToList
        ;
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
            privateKeyPath = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
          };
        };

        workspaces = mkOption {
          default = {};
          description = "Configuraciones de Git aplicadas solo en carpetas específicas";
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
                  privateKeyPath = mkOption {
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

          extraConfig = mkMerge [
            (mkIf (cfg.global.enable && cfg.global.ssh.enableAuth) {
              core.sshCommand = "ssh -i ${cfg.global.ssh.privateKeyPath} -o IdentitiesOnly=yes";
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
                commit = optionalAttrs ws.gpg.enable {
                  gpgsign = true;
                };
                core = optionalAttrs ws.ssh.enableAuth {
                  sshCommand = "ssh -i ${ws.ssh.privateKeyPath} -o IdentitiesOnly=yes";
                };
              };
            })
            cfg.workspaces;
        };
      };
    };
  };
}
