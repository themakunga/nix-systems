# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
let
  f = builtins.getFlake (toString ../.);
  inherit (f.darwinConfigurations.kanagawa) pkgs;
  inherit (pkgs) lib;
  names = ["codex" "claude-code" "opencode" "gemini-cli" "llama"];
  evaluate = enabled: service: darwin:
    (lib.evalModules {
      modules = [
        f.commonModules.apps
        f.applicationModules.ai
        {
          options =
            {
              environment.systemPackages = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [];
              };
              environment.interactiveShellInit = lib.mkOption {
                type = lib.types.lines;
                default = "";
              };
              my = {
                agentWiki.enable = lib.mkEnableOption "test vault";
                claudeHooks.enable = lib.mkEnableOption "test hooks";
                dotfiles = {
                  enable = lib.mkEnableOption "test dotfiles";
                  user = lib.mkOption {default = "test";};
                  home = lib.mkOption {default = "/tmp/ai-test";};
                  packages = lib.mkOption {
                    type = lib.types.listOf lib.types.attrs;
                    default = [];
                  };
                };
              };
            }
            // (
              if darwin
              then {
                launchd.user.agents = lib.mkOption {
                  type = lib.types.attrs;
                  default = {};
                };
              }
              else {
                systemd.user.services = lib.mkOption {
                  type = lib.types.attrs;
                  default = {};
                };
              }
            );
          config = {
            _module.args.pkgs = pkgs;
            my.apps =
              (lib.genAttrs names (name: {enable = builtins.elem name enabled;}))
              // {
                llama = {
                  enable = builtins.elem "llama" enabled;
                  server.enable = service;
                  port = 8181;
                  maxModels = 2;
                  extraArgs = ["--cache-type-k" "q8_0"];
                };
              };
          };
        }
      ];
    }).config;
  only = name: let
    c = evaluate [name] false true;
    packages = map (p: p.pname or p.name) c.environment.systemPackages;
  in
    assert builtins.all (other: c.my.apps.${other}.enable == (other == name)) names;
    assert builtins.all (other: other == name || !(builtins.elem other packages)) names;
    assert c.my.agentWiki.enable == (name != "llama");
    assert c.my.claudeHooks.enable == (name == "claude-code");
    assert c.launchd.user.agents == {}; true;
  disabled = evaluate [] false true;
  mac = evaluate ["llama"] true true;
  linux = evaluate ["llama"] true false;
  args = mac.launchd.user.agents.llama-router.serviceConfig.ProgramArguments;
in
  assert disabled.environment.systemPackages == [];
  assert disabled.my.dotfiles.packages == [];
  assert builtins.all only names;
  assert builtins.elem "8181" args && builtins.elem "2" args && builtins.elem "q8_0" args;
  assert builtins.match ".*ai-server.*8181.*" linux.systemd.user.services.llama-router.serviceConfig.ExecStart != null; {
    independentSwitches = true;
    configurableRouterOnDarwinAndLinux = true;
  }
