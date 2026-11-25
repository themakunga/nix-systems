# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Run: nix eval --impure --json --file scripts/check-aperture-workspace.nix
let
  f = builtins.getFlake (toString ../.);
  cfg = f.nixosConfigurations.aperture-science.config;
  names = map (p: p.pname or p.name) cfg.environment.systemPackages;
in
  assert cfg.my.apps.coding-agents.enable;
  assert cfg.my.apps.agent-workspace.enable;
  assert cfg.my.dotfiles.user == "wheatley";
  assert cfg.my.dotfiles.home == "/opt/wheatley";
  assert builtins.all (n: builtins.elem n names) ["codex" "lua" "taplo" "jq"];
  assert builtins.all (d: builtins.elem d cfg.system.activationScripts.seedAgentWorkspace.deps)
  ["setupSecrets" "stowDotfiles" "agent-wiki-setup" "seedUbMode"];
  assert builtins.all (h: !(f.darwinConfigurations.${h}.config.my.apps.agent-workspace.enable or false))
  ["kanagawa" "outer-heaven"]; {wheatleyCodexWorkspace = true;}
