{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "Infra-development-environment";

        nativeBuildInputs = with pkgs; [
          git
          fd
          fzf
          bat
          lazygit
          pre-commit
          nixpkgs-fmt
          nodePackages.prettier
          nodejs_24
          python3
          commitlint

          nixd
          alejandra
          unstable.neovim
        ];

        shellHook = ''
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
