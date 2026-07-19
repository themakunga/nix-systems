# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  inputs,
  mkAppModule,
}: let
  inherit (inputs) dotfiles;
in
  mkAppModule "neovim" "Enable NeoVim configueration" ({
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
        xdg.configDile."nvim" = {
          source = "${dotfiles}/neovim";
          recursive = true;
        };
      }
    ];
  })
