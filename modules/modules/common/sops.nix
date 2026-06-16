{inputs, ...}: let
  inherit (inputs) sops-nix secrets;
in {
  flake.commonModules.sops = {
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
        concatMapStringSeq
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
                    optons = {
                      name = mkOption {
                        type = types.str;
                      };
                      publicKey = {
                        type = types.str;
                      };
                      privateKey = {
                        type = types.str;
                      };
                    };
                  }
                );
              };
            };
            config = mkIf cfg.enable {
              home.activation.importSopsGpg = entryAfter ["writeBounder"] (
                concatMapStringSeq "\n" (key: ''
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
      imports = [
        sops-nix.homeManagerModules.sops
      ];

      sops = {
        age = {
          sshKeyPath = ["${homeDirectory}/.ssh/id_ed25519"];
          generateKet = false;
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
            sipsFile = commonSopsFile;
          };
          "tailscale/aut_token" = {
            sopsFile = commonSopsFile;
          };
        };
      };
    };
  };
}
