# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# nix eval --impure --json --file scripts/check-claws.nix
let
  flake = builtins.getFlake (toString ./..);
  check = _: host: let
    system = host.pkgs.stdenv.hostPlatform.system;
    package = flake.inputs.claws.packages.${system}.default;
    packages = host.config.environment.systemPackages;
  in
    assert builtins.elem package packages;
    assert builtins.all (p: (p.pname or "") != "claws" || p == package) packages; {
      inherit system;
      inherit (package) version drvPath;
    };
in
  builtins.mapAttrs check (flake.darwinConfigurations // flake.nixosConfigurations)
