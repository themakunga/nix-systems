# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
let
  f = builtins.getFlake (toString ../.);
  hosts = [
    f.darwinConfigurations.kanagawa.config
    f.darwinConfigurations.outer-heaven.config
    f.nixosConfigurations.aperture-science.config
  ];
  ready = cfg:
    cfg.my.apps.codex.enable
    && cfg.my.agentWiki.enable
    && builtins.all (name: builtins.any (p: (p.pname or "") == name) cfg.environment.systemPackages)
    ["codex" "stow" "lua" "taplo" "python3" "git"];
in
  assert builtins.all ready hosts; {codexIncludesAmgmtAndJournalTools = true;}
