# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# nix eval --json --file scripts/check-ghostty.nix
let
  module = import ../modules/applications/ghostty.nix {
    self.lib.mkAppModule = _: _: definition: definition;
  };
  metaFor = isDarwin:
    module.flake.applicationModules.ghostty.meta {
      lib.optionals = condition: values:
        if condition
        then values
        else [];
      pkgs = {
        stdenv.hostPlatform = {
          inherit isDarwin;
          isLinux = !isDarwin;
        };
        ghostty =
          if isDarwin
          then throw "Ghostty must not be evaluated from nixpkgs on Darwin"
          else "ghostty-linux";
      };
    };
  darwin = metaFor true;
  linux = metaFor false;
in
  assert darwin.packages == [];
  assert darwin.casks == ["ghostty"];
  assert linux.packages == ["ghostty-linux"];
  assert linux.casks == []; true
