# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{inputs, ...}: let
  inherit (inputs) dotfiles;
  mkAppModule = name: description: appConfig: {
    lib,
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.${name};
  in {
    options.my.${name}.enable = mkEnableOption description;

    config = mkIf cfg.enable (
      if builtins.isFunction appConfig
      then appConfig {inherit pkgs lib config;}
      else appConfig
    );
  };
in {
  flake.commonModules.applications = {
    neovim = mkAppModule "neovim" "Enable neovim configured" ({
      pkgs,
      lib,
      ...
    }: {
      my.apps.neovim = {
        enable = true;
        level = "system";
        apps =
          [
            "alejandra"
            "curl"
            "fg"
            "fzf"
            "gcc"
            "git"
            "gnumake"
            "lazygit"
            "lua-language-server"
            "neovim"
            "nil"
            "nodejs_24"
            "python3"
            "ripgrep"
            "stylua"
            "tree-sitter"
            "unzip"
            "wget"
          ]
          ++ lib.optionals pkgs.stdenv.isLinux [
            "wl-clipboard"
            "xclip"
          ];
      };

      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      home-manager.sharedModules = [
        {
          xdg.configFile."nvim" = {
            source = "${dotfiles}/nvim";
            recursive = true;
            force = true;
          };
        }
      ];
    });
    terminal = mkAppModule "terminal" "Terminal Applications and tools" {
      my.apps.terminal = {
        enable = true;
        level = "system";
        apps = [
          "wezterm"
          "tmux"
          "fzf"
          "lazygit"
          "lazyaws"
          "lazysql"
          "git"
          "neofetch"
        ];
      };

      home-manager.sharedModules = [
        {
          home.file = {
            ".tmux.conf" = {
              source = "${dotfiles}/.tmux.conf";
              force = true;
            };
            ".wezterm" = {
              source = "${dotfiles}/.wezterm";
              force = true;
            };
          };
        }
        {
          xdg.configFile = {
            "neofetch" = {
              source = "${dotfiles}/neofetch";
              recursive = true;
              force = true;
            };
          };
        }
      ];
    };
  };
}
