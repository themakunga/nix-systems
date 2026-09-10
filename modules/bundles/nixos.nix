# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# NixOS base bundle: modules shared by all x86_64 NixOS machines.
# Extend with extendBundle in each host file — never edit entries here per-host.
_: {
  flake.bundle.nixos = {
    base = {
      commonModules = [
        "dotfiles"
        "arch.nixos.x64"
        "authorized-keys"
        "host-secrets"
        "network"
        "settings"
        "userProfiles"
        "apps"
        "git-identity"
        "sops-gpg"
        "shared-plain"
      ];

      nixosModules = [
        "base-machine"
        "keyboard"
      ];

      applicationModules = ["tailscale.core"];

      profileModules = ["nixos-x64"];
    };
  };
}
