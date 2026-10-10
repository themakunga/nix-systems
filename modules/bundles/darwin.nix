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
        "agent-wiki"
        "claude-hooks"
        "shared-plain"
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
        "locale"
        "dock"
        "finder"
        "mail"
        "homebrew"
        "keyboard"
        "primaryUser"
        "security"
        "janitor"
        "agent-wiki-sync"
      ];

      applicationModules = [
        "glados-tts"
        "bat"
        "qmk"
        "glow"
        "yazi"
        "zoxide"
        "github-cli"
        "ghostty"
        "halloy"
        "nchat"
        "beeptui"
        "weechat"
        "neovim"
        "obsidian"
        "openconnect"
        "tailscale.core"
        "tailscale.gui"
        "terminal-zsh"
        "newsboat"
        "token-counter"
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
