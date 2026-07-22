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
        lazygit
        lazysql
        fastfetch
        oh-my-posh
        tmux
        wezterm
        zstd
      ];
    };
    sysConfig = {
      pkgs,
      lib,
      ...
    }: {
      fonts.packages = [
        pkgs.nerd-fonts.hack
      ];

      system.activationScripts.terminalProfile = lib.mkIf pkgs.stdenv.isDarwin {
        text = ''
          echo "Setting up macOS Terminal profile..."
          if ! defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -q "TokyoNight-Storm"; then
            open -g -a Terminal.app "${dotfiles}/terminal/TokyoNight-Storm.terminal"
            sleep 1
          fi
          defaults write com.apple.Terminal "Default Window Settings" -string "TokyoNight-Storm"
          defaults write com.apple.Terminal "Startup Window Settings" -string "TokyoNight-Storm"
        '';
      };

      home-manager.sharedModules = [
        {
          home.file = {
            ".tmux.conf" = {
              source = "${dotfiles}/.tmux.conf";
              force = true;
            };
            ".wezterm.lua" = {
              source = "${dotfiles}/.wezterm.lua";
              force = true;
            };
            ".zshrc" = {
              source = "${dotfiles}/.zshrc";
              force = true;
            };
            ".zsh" = {
              source = "${dotfiles}/.zsh";
              recursive = true;
              force = true;
            };
          };
        }
        {
          xdg.configFile = {
            "fastfetch" = {
              source = "${dotfiles}/fastfetch";
              recursive = true;
              force = true;
            };
            "lazygit" = {
              source = "${dotfiles}/lazygit";
              recursive = true;
              force = true;
            };
            "ohmyposh" = {
              source = "${dotfiles}/ohmyposh";
              recursive = true;
              force = true;
            };
          };
        }
      ];
    };
  };
}
