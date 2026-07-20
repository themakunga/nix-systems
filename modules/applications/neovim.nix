# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  inputs,
  self,
  ...
}: let
  inherit (inputs) dotfiles;
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.neovim = mkAppModule "neovim" "Enable NeoVim configuration" ({
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) optionals;
    inherit (pkgs.stdenv) isLinux;
  in {
    my.apps.neovim = {
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
        ++ optionals isLinux [
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
          source = "${dotfiles}/neovim";
          recursive = true;
        };
      }
    ];
  });
}
