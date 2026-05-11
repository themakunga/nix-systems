{
  inputs,
  self,
  lib,
  ...
}:
with lib; {
  options = {
    flake = {
      darwinConfigurations = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
      darwinModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
      commonModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
      usersModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
      diskModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
      builderModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
      linuxModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
      sharedModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
      homeModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
    };
  };

  config = {
    flake = {
      commonModules = {
        secrets-management = {
          config,
          pkgs,
          lib,
          ...
        }: let
          hostname = config.networking.hostName;
          hostSecretsFile = inputs.secrets + "/hosts/${hostname}.yaml";
          commonSecretsFile = inputs.secrets + "/common.yaml";
        in {
          environment.systemPackages = [pkgs.sops];

          sops = {
            defaultSopsFile = hostSecretsFile;
            defaultSopsFormat = "yaml";

            age.keyFile = lib.mkMerge [
              (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin "/var/root/sops/age/key.txt")
              (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "/var/lib/sops-nix/key.txt")
            ];

            secrets = {
              "shared/wifi_house" = {
                sopsFile = commonSecretsFile;
              };
              "shared/wifi_42devs" = {
                sopsFile = commonSecretsFile;
              };
            };
          };
        };
        home-manager-conf = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
        state-version = {
          pkgs,
          lib,
          ...
        }:
          with lib;
            mkMerge [
              (mkIf pkgs.stdenv.hostPlatform.isLinux {
                system.stateVersion = "25.11";
              })
              (mkIf pkgs.stdenv.hostPlatform.isDarwin {
                system.stateVersion = 6;
              })
            ];

        nix-settings = {
          pkgs,
          lib,
          ...
        }: {
          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users =
              [
                "root"
                "nicolas"
              ]
              ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux ["@wheel"]
              ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin ["@admin"];
          };
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            self.overlays.unstable
          ];
        };
      };
    };
  };
}
