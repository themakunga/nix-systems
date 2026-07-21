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
  flake.applicationModules.neovim = mkAppModule "neovim" "Enable NeoVim configuration" {
    meta = {
      pkgs,
      options,
      lib,
      ...
    }: {
      level = "system";
      packages = with pkgs;
        [
          alejandra
          curl
          fg
          fzf
          gcc
          git
          gnumake
          lazygit
          lua-language-server
          neovim
          nil
          nodejs_24
          python3
          ripgrep
          stylua
          tree-sitter
          unzip
          wget
        ]
        ++ lib.optionals (options ? system.nixos) [wl-clipboard xclip];
    };
    sysConfig = {
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
    };
  };
}
