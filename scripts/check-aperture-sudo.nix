# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Run: nix eval --impure --json --file scripts/check-aperture-sudo.nix
let
  flake = builtins.getFlake (toString ../.);
  cfg = flake.nixosConfigurations.aperture-science.config;
in
  assert cfg.security.sudo.enable;
  assert !cfg.security.sudo.wheelNeedsPassword;
  assert cfg.my.userProfiles.wheatley.isAdmin;
  assert builtins.elem "wheel" cfg.users.users.wheatley.extraGroups;
  assert builtins.elem "wheel" cfg.users.users.nicolas.extraGroups;
  assert builtins.all (user: !(builtins.elem "wheel" cfg.users.users.${user}.extraGroups)) ["glados" "hermes"]; {wheatleyPasswordlessSudo = true;}
