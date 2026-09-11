# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# NixOS host: msf — x86_64 media server.
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
  flake.nixosConfigurations.msf = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "msf";
    };

    modules =
      [
        sops-nix.nixosModules.sops
      ]
      ++ (mkBundle (extendBundle bundles.nixos.base {
        userModules = ["media"];
        profileModules = ["mediaserver"];
      }))
      ++ [
        {
          my = {
            hostSecrets.file = "${secrets.outPath}/hosts/msf.yaml";
            base-machine = {
              enable = true;
              bootMode = "uefi";
              rootDevice = "/dev/nvme0u1p2";
            };
          };
        }
      ];
  };
}
