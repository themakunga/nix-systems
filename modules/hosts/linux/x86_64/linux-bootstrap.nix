# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# NixOS host: linux-bootstrap — ISO de instalación genérica x86_64.
# Bootea desde USB/PXE para instalar cualquier host x86 vía nixos-anywhere.
# Incluye todas las llaves SSH del repositorio de secretos para acceso inmediato.
{
  self,
  inputs,
  ...
}: let
  inherit (inputs) nixpkgs;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;

  # Lee TODAS las llaves públicas del repo de secretos — cualquier equipo
  # autorizado puede conectarse al installer sin configuración adicional.
  pubKeys = builtins.fromJSON (builtins.readFile "${inputs.secrets}/public_keys.json");
  allKeys = builtins.map (k: k.public_key) (builtins.attrValues pubKeys.ssh);
in {
  flake.nixosConfigurations.linux-bootstrap = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "linux-bootstrap";
    };

    modules =
      [
        # Base NixOS minimal: habilita el builder de ISO, live-system, etc.
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ]
      ++ (mkBundle {
        commonModules = [
          "arch.nixos.x64"
          "authorized-keys"
          "network"
        ];
      })
      ++ [
        (_: {
          networking.hostName = "nixos-installer";

          # SSH habilitado, acceso root sin contraseña (solo llaves)
          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "yes";
              PasswordAuthentication = false;
            };
          };

          # Inyectar todas las llaves del secreto para acceso inmediato
          my.authorizedKeys = {
            enable = true;
            assignTo = ["root"];
            keys = allKeys;
          };

          # Nix con flakes habilitado — requerido por nixos-anywhere
          nix.settings.experimental-features = ["nix-command" "flakes"];

          # Contraseña temporal para acceso por consola (solo installer)
          users.users.root.initialPassword = "nixos";

          system.stateVersion = "26.05";
        })
      ];
  };
}
