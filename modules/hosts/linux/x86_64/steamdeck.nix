# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# NixOS host: steamdeck — x86_64 Steam Deck (gaming + portable dev).
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
  flake.nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "steamdeck";
    };

    modules =
      [
        sops-nix.nixosModules.sops
      ]
      ++ (mkBundle (extendBundle bundles.nixos.base {
        applicationModules = ["tailscale.gui"];
        userModules = ["deck"];
        profileModules = ["steamdeck"];
      }))
      ++ [
        {
          my = {
            hostSecrets.file = "${secrets.outPath}/hosts/steamdeck.yaml";
            base-machine = {
              enable = true;
              bootMode = "uefi";
              rootDevice = "/dev/nvme0u1p2";
            };
            apps.tailscale-gui.enable = true;
          };
        }
      ];
  };
}
