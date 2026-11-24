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
    }: let
      tmuxPlugins = with pkgs.tmuxPlugins; [
        {
          name = "tmux-resurrect";
          plugin = resurrect;
        }
        {
          name = "tmux-continuum";
          plugin = continuum;
        }
        {
          name = "vim-tmux-navigator";
          plugin = vim-tmux-navigator;
        }
        {
          name = "tmux-sessionx";
          plugin = tmux-sessionx;
        }
        {
          name = "tmux-which-key";
          plugin = tmux-which-key;
        }
      ];
    in {
      programs.zsh = lib.mkIf pkgs.stdenv.isLinux {
        enable = true;
        enableGlobalCompInit = false;
        promptInit = "";
      };

      environment.etc = lib.mkIf pkgs.stdenv.isLinux {
        "zsh/plugins.zsh".text = ''
          fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
          export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
          ZSH_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
          ZSH_THEME=""
          zstyle ':omz:update' mode disabled
          plugins=(git sudo aws docker gitignore node)
          source "$ZSH/oh-my-zsh.sh"
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
          source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
          source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        '';
        "tmux/plugins".source = pkgs.linkFarm "tmux-plugins" (map (entry: {
            inherit (entry) name;
            path = builtins.dirOf entry.plugin.rtp;
          })
          tmuxPlugins);
        "tmux/plugins.conf".text = ''
          set-environment -g TMUX_PLUGIN_MANAGER_PATH /etc/tmux/plugins/
          set -g @tmux-which-key-xdg-enable true
          run-shell 'mkdir -p "''${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tmux-which-key" "''${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tmux-which-key"'
          # The packaged example is read-only; seed a writable generated menu.
          run-shell 'touch "''${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tmux-which-key/init.tmux" && chmod u+w "''${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tmux-which-key/init.tmux"'
          ${lib.concatMapStringsSep "\n" (entry: "run-shell ${entry.plugin.rtp}") tmuxPlugins}
        '';
      };

      my.dotfiles.packages = [
        {
          name = "git";
          isConfig = true;
        }
        {
          name = "zsh";
        }
        {
          name = "tmux";
        }
        {
          name = "btop";
          isConfig = true;
        }
        {
          name = "htop";
          isConfig = true;
        }
        {
          name = "fastfetch";
          isConfig = true;
        }
        {
          name = "lazygit";
          isConfig = true;
        }
        {
          name = "ohmyposh";
          isConfig = true;
        }
      ];

      fonts.packages = [
        pkgs.nerd-fonts.hack
      ];

      system.activationScripts = lib.mkIf pkgs.stdenv.isDarwin {
        postActivation.text = ''
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
