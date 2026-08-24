# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: darwin.nix
# Path: ./modules/bundles/darwin.nix
# Description: Bundle specs compartidos para hosts Darwin.
#              Usar con self.lib.extendBundle en archivos de host.
#
#   let
#     mkBundle     = self.lib.mkBundle inputs.nixpkgs.lib self;
#     extendBundle = self.lib.extendBundle;
#     bundles      = self.bundle;
#   in mkBundle (extendBundle bundles.darwin.base {
#     commonModules = [ "cloud-profiles" ];
#     userModules   = [ "work" "glados" ];
#   })
# =====================
_: {
  flake.bundle.darwin = {
    # -------------------------------------------------------
    # base: módulos comunes a TODOS los hosts Darwin.
    # Extender con extendBundle, nunca editar por host.
    # -------------------------------------------------------
    base = {
      commonModules = [
        "dotfiles"
        "apps"
        "arch.darwin.silicon"
        "host-secrets"
        "network"
        "settings"
        "userProfiles"
        "home-secrets"
        "git-identity"
        "sops-gpg"
        "devenv"
        "wallpaper"
        "weather"
      ];

      darwinModules = [
        "extras"
        "finder"
        "homebrew"
        "keyboard"
        "primaryUser"
        "security"
        "janitor"
      ];

      applicationModules = [
        "github-cli"
        "neovim"
        "openconnect"
        "tailscale.core"
        "tailscale.gui"
        "terminal-zsh"
      ];

      deviceModules = [
        "audio"
        "logitech"
        "sony"
        "hyperx"
      ];

      developmentModules = [
        "argocd"
        "aws"
        "containers"
        "gcp"
        "golang"
        "groovy"
        "iac"
        "java"
        "nodejs"
        "python"
        "ruby"
        "rust"
        "swift"
      ];
    };
  };
}
