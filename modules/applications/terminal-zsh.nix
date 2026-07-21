# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{
  inputs,
  self,
  ...
}: let
  inherit (inputs) dotfiles;
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.terminal-zsh = mkAppModule "terminal-zsh" "Enable zsh as main terminal" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = with pkgs; [
        fzf
        lazyaws
        lazygit
        lazysql
        neofetch
        oh-my-posh
        tmux
        wezterm
      ];
    };
    sysConfig = {
      home-manager.sharedModules = [
        {
          home.file = {
            ".wezterm.lua".source = "${dotfiles}/.wezterm.lua";
            ".tmux.conf".source = "${dotfiles}/.tmux.conf";
            ".zshrc".source = "${dotfiles}/.zshrc";
            ".zsh" = {
              source = "${dotfiles}/.zsh";
              recursive = true;
            };
          };
        }
        {
          xdg.configFile = {
            "neofetch" = {
              source = "${dotfiles}/neofetch";
              recursive = true;
            };
            "lazygit" = {
              source = "${dotfiles}/lazygit";
              recursive = true;
            };
            "ohmyposh" = {
              source = "${dotfiles}/ohmyposh";
              recursive = true;
            };
          };
        }
      ];
    };
  };
}
