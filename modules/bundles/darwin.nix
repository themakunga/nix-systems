# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Darwin base bundle: common modules shared by all macOS workstations.
# Extend with extendBundle in each host file — never edit entries here per-host.
{
  flake.bundle.darwin = {
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
        "workspace-identity"
        "devenv"
        "wallpaper"
        "weather"
      ];

      darwinModules = [
        "extras"
        "dock"
        "finder"
        "mail"
        "homebrew"
        "keyboard"
        "primaryUser"
        "security"
        "janitor"
      ];

      applicationModules = [
        "glados-tts"
        "bat"
        "glow"
        "yazi"
        "zoxide"
        "github-cli"
        "ghostty"
        "halloy"
        "neovim"
        "openconnect"
        "tailscale.core"
        "tailscale.gui"
        "terminal-zsh"
        "wezterm"
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

      profileModules = ["terminal-tools" "darwin-mac"];
    };
  };
}
