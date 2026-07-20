{
  inputs,
  mkAppModule,
}: let
  inherit (inputs) dotfiles;
in
  mkAppModule "terminal-zsh" "Enable zsh as main terminal" {
    my.apps.terminal-zsh = {
      enable = true;
      level = "system";
      apps = [
        "fzf"
        "lazyaws"
        "lazygit"
        "lazysql"
        "neofetch"
        "oh-my-posh"
        "tmux"
        "wezterm"
      ];
    };

    home-manager.sharedModules = [
      {
        home.file = {
          ".wezterm.lua" = {
            source = "${dotfiles}/.wezterm.lua";
          };
          ".tmux.conf" = {
            source = "${dotfiles}/.tmux.conf";
          };
          ".zshrc" = {
            source = "${dotfiles}/.zshrc";
          };
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
  }
