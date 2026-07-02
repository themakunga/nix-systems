{inputs, ...}: let
  inherit (inputs) sops-nix secrets;
in {
  flake.commonModules = {
    # 1. GPG para Home Manager
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
    };

    # 2. Secretos a nivel de SISTEMA (NixOS)
    nixos-secrets = {lib, ...}: let
      commonSopsFile = "${secrets}/common.yaml";
    in {
      imports = [sops-nix.nixosModules.sops];

      sops = {
        defaultSopsFile = lib.mkDefault commonSopsFile;
        # NixOS usa la llave del host por defecto para desencriptar
        age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      };
    };

    # 3. Secretos a nivel de USUARIO (Home Manager)
    home-secrets = {
      lib,
      config,
      ...
    }: let
      inherit (config.home) homeDirectory;
      commonSopsFile = "${secrets}/common.yaml";
    in {
      imports = [sops-nix.homeManagerModules.sops];

      sops = {
        secrets = {
          "wifi/AMANDA".sopsFile = commonSopsFile;
          "wifi/42DEVS_5G".sopsFile = commonSopsFile;
          "wifi/42DEVS".sopsFile = commonSopsFile;
          "tailscale/auth_token".sopsFile = commonSopsFile;
        };
      };
    };

    # 4. Git Identity
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
