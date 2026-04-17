{ pkgs, ... }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nixfmt-rfc-style
    statix
    deadnix
    pre-commit
  ];

  shellHook = ''
    pre-commit install --hook-type pre-commit --hook-type commit-msg > /dev/null
    echo "Dev ENV ready, pre-commit"
  '';
}
