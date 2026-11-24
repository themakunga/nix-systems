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
          imagemagick # snacks.image: convert/magick para rendering
          ghostscript # snacks.image: gs para PDFs
          lua-language-server
          (pkgs.callPackage ../../packages/agnix-lsp/package.nix {})
          (writeShellScriptBin "cspell-language-server" ''
            exec ${nodejs_24}/bin/node ${unstable.vscode-extensions.streetsidesoftware.code-spell-checker}/share/vscode/extensions/streetsidesoftware.code-spell-checker/packages/_server/dist/main.cjs "$@"
          '')
          stylua
          nixd
          alejandra
          efm-langserver
          yaml-language-server
          actionlint
          gitlab-ci-ls
          nodejs_24
          python3
          jq
          go
          jdk
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [pngpaste]
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
