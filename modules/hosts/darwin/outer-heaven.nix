# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: outer-heaven.nix
# Path: ./modules/hosts/darwin/outer-heaven.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nix-darwin
    nix-homebrew
    home-manager
    sops-nix
    secrets
    ;
  inherit
    (self)
    commonModules
    userModules
    darwinModules
    profileModules
    applicationModules
    ;
in {
  flake.darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "outer-heaven";
    };

    modules = [
      sops-nix.darwinModules.sops
      nix-homebrew.darwinModules.nix-homebrew
      home-manager.darwinModules.home-manager
      commonModules.home-manager

      commonModules.arch.darwin.silicon
      commonModules.settings
      commonModules.host-secrets
      commonModules.userProfiles
      commonModules.network

      darwinModules.primaryUser
      darwinModules.keyboard
      darwinModules.security
      darwinModules.dock
      darwinModules.finder
      darwinModules.extras
      darwinModules.homebrew

      applicationModules.apps
      applicationModules.tailscale
      applicationModules.gh

      userModules.nicolas-work

      profileModules.nicolas-work
      profileModules.thoughtworks
      profileModules.grainger

      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/outer-heaven.yaml";
          tailscale = {
            enable = true;
            gui.enable = true;
          };
          primaryUser = {
            enable = true;
            username = "nicolas";
          };
          keyboard.enable = true;
          apps = {
            outer-heaven = {
              enable = true;
              level = "system";
              apps = [
                "Xcode"
                "logitech-g-hub"
                "Magnet"
                "Amphetamine"
                "iterm2"
                "wezterm"
                "tmux"
                "stow"
              ];
            };
          };
        };
      }
    ];
  };
}
