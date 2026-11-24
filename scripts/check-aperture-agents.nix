# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Run: nix eval --impure --json --file scripts/check-aperture-agents.nix
let
  flake = builtins.getFlake (toString ../.);
  cfg = flake.nixosConfigurations.aperture-science.config;
  names = map (p: p.pname or p.name) cfg.environment.systemPackages;
  private = name: let
    s = cfg.sops.secrets.${name};
  in
    s.owner == "root" && s.group == "coding-agents" && s.mode == "0440";
in
  assert builtins.all (name: builtins.elem name names) ["codex" "claude-code" "gemini-cli" "hermes-agent" "btop" "htop" "gh" "glab" "newsboat" "glow" "crapper" "dryer" "mutator" "uml-viewer"];
  assert cfg.users.groups.coding-agents.members == ["wheatley" "nicolas"];
  assert builtins.all private ["applications/gh/token" "codex-auth" "agents/gemini-personal/api_key"];
  assert cfg.sops.secrets.codex-auth.format == "binary";
  assert cfg.sops.secrets."applications/gh/token".format == "binary";
  assert cfg.my.agentWiki.githubTokenFile == cfg.sops.secrets."applications/gh/token".path;
  assert cfg.my.agentWiki.additionalUsers
  == [
    {
      user = "nicolas";
      home = "/home/nicolas";
    }
  ];
  assert builtins.elem "setupSecrets" cfg.system.activationScripts.seedCodingAgents.deps;
  assert builtins.elem "seedCodingAgents" cfg.system.activationScripts.agent-wiki-setup.deps;
  assert cfg.systemd.services.zeroclaw.serviceConfig.User == "glados"; {packagesAndPrivateAuthentication = true;}
