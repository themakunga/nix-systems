{ pkgs }:
pkgs.mkShell {
  name = "dev-shell";
  buildInputs =
    (import ../modules/dev-tools.nix {
      inherit pkgs;
    }).environment.systemPackages;

  shellHook = ''
    echo "Welcome to Aperture Science / Thoughtworks Environment"
    echo "Platform: $(uname -m)"
  '';
}
