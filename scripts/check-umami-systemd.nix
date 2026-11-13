# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Run: nix eval --impure --json --file scripts/check-umami-systemd.nix
let
  flake = builtins.getFlake (toString ./..);
  check = useSystemdActivation: let
    cfg =
      (flake.nixosConfigurations.motherbase.extendModules {
        modules = [{sops.useSystemdActivation = useSystemdActivation;}];
      }).config;
    service = cfg.systemd.services.compose-umami;
    defined = unit:
      builtins.hasAttr unit cfg.systemd.units
      || throw "compose-umami requires an undefined unit: ${unit}";
  in
    assert builtins.all defined service.requires;
    assert builtins.all (unit: builtins.elem unit service.after) service.requires;
    assert builtins.elem "podman.socket" service.requires;
    assert !(builtins.elem "docker.service" service.requires);
    assert !(builtins.elem "compose-main.service" service.requires);
    assert !useSystemdActivation || builtins.elem "sops-install-secrets.service" service.requires;
    assert service.serviceConfig.EnvironmentFile == cfg.sops.templates."umami-env".path; true;
in {
  activationScript = check false;
  systemdActivation = check true;
}
