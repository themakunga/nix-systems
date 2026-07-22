# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{self, ...}: let
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
        sops
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
            open -g -a Terminal.app "/Users/nicolas/Projects/personal/public-dotfiles/terminal/TokyoNight-Storm.terminal"
            sleep 1
          fi
          defaults write com.apple.Terminal "Default Window Settings" -string "TokyoNight-Storm"
          defaults write com.apple.Terminal "Startup Window Settings" -string "TokyoNight-Storm"
        '';
      };
    };
  };
}
