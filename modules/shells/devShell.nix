# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: devShell.nix
# Path: ./modules/shells/devShell.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      name = "Infra-development-environment";

      nativeBuildInputs = with pkgs; [
        zsh
        oh-my-posh
        git
        gcc
        fd
        fzf
        bat
        lazygit
        sops
        pre-commit
        statix
        deadnix
        nixpkgs-fmt
        prettier
        nodejs
        python3
        commitlint

        nixd

        alejandra
        unstable.neovim
        unstable.tree-sitter
      ];

      shellHook = ''
        exec zsh
        eval "$(oh-my-posh init zsh)"

        echo "======================================="
        echo "===== Entorno de Desarrollo Nix ======="
        echo "======================================="

        if [ ! -f .git/hooks/pre-commit ]; then
          echo "Installing git hooks"
          pre-commit install
          pre-commit install --hooks-type commit-msg --hooks-type pre-commit
        fi
      '';
    };
  };
}
