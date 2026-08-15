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
          neovim
          curl
          fd
          fzf
          gcc
          git
          gnumake
          ripgrep
          tree-sitter
          unzip
          wget
          cargo
          rustc
          lazygit
          gh
          pandoc
          texliveSmall
          lua-language-server
          stylua
          nixd
          alejandra
          efm-langserver
          yaml-language-server
          nodejs_24
          python3
        ]
        ++ lib.optionals (options ? system.nixos) [wl-clipboard xclip];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "nvim";
          isConfig = true;
        }
      ];
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
  };
}
