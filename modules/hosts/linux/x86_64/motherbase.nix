# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# NixOS host: motherbase — x86_64 home server (infrastructure node).
{
  self,
  inputs,
  ...
}: let
  inherit (inputs) nixpkgs sops-nix secrets;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
  extendBundle = self.lib.extendBundle;
  bundles = self.bundle;
in {
  flake.nixosConfigurations.motherbase = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "motherbase";
    };

    modules =
      [
        sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko
      ]
      ++ (mkBundle (extendBundle bundles.nixos.base {
        nixosModules = ["disko-x86" "nix-anywhere"];
        applicationModules = ["podman" "docker-host" "samba-share"];
        userModules = ["nicolas-server"];
        profileModules = ["nicolas-server"];
      }))
      ++ [
        {
          # Declaramos primaryUser localmente para satisfacer al módulo nix-anywhere
          options.my.primaryUser.username = nixpkgs.lib.mkOption {
            type = nixpkgs.lib.types.str;
            default = "nicolas";
          };

          config.my = {
            primaryUser.username = "nicolas";
            nix-anywhere.enable = true;
            hostSecrets.file = "${secrets.outPath}/hosts/motherbase.yaml";

            base-machine = {
              enable = true;
              bootMode = "uefi";
              rootDevice = "/dev/sda3"; # fallback, disko gestiona el mount
            };

            apps = {
              podman.enable = true;
              docker-host.enable = true;
              samba-share.enable = true;
            };

            services = {
              docker-host = {
                # Un túnel por entrada; agregar más con un tokenSecret distinto en .secrets
                tunnels.primary.tokenSecret = "cloudflare-tunnel-token";
                # Proyectos: path estático en nix-systems. Traefik los descubre via labels.
                projects.demo = "${self}/modules/applications/docker-host/demo";
              };
              samba-share.user = "admin";
            };
          };
        }
      ];
  };
}
