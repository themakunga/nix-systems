# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# nix eval --impure --json --file scripts/check-containers.nix
let
  flake = builtins.getFlake (toString ./..);
  host = flake.darwinConfigurations.kanagawa;
  lib = flake.inputs.nixpkgs.lib;
  check = runtime: let
    config =
      (host.extendModules {
        modules = [{my.development.containers.runtime = lib.mkForce runtime;}];
      }).config;
    packages = config.environment.systemPackages;
    podman = runtime == "podman";
  in
    assert builtins.all (name: builtins.elem host.pkgs.${name} packages) [runtime "docker-client" "docker-compose"];
    assert (builtins.hasAttr "podman" config.launchd.user.agents) == podman;
    assert (builtins.hasAttr "colima" config.launchd.user.agents) == (!podman);
    assert config.environment.variables.DOCKER_HOST
    == (
      if podman
      then "unix:///Users/${config.system.primaryUser}/.local/share/containers/podman/docker.sock"
      else "unix:///Users/${config.system.primaryUser}/.colima/default/docker.sock"
    ); true;
in {
  podman = check "podman";
  colima = check "colima";
}
