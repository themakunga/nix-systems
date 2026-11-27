# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.ai = {
    config,
    lib,
    options,
    pkgs,
    ...
  }: let
    apps = config.my.apps;
    llama = apps.llama;
    coding = apps.codex.enable || apps.claude-code.enable || apps.opencode.enable || apps.gemini-cli.enable;
    local = llama.enable || apps.opencode.enable;
    user = config.my.dotfiles.user;
    home =
      if config.my.dotfiles.home != null
      then config.my.dotfiles.home
      else
        (
          if pkgs.stdenv.isDarwin
          then "/Users/${user}"
          else "/home/${user}"
        );
    tools = with pkgs;
      [jq curl coreutils gnugrep bash python3]
      ++ lib.optionals llama.enable [llama.package unstable.stable-diffusion-cpp unstable.whisper-cpp ffmpeg]
      ++ lib.optional apps.opencode.enable unstable.opencode;
    commands = ["ai" "ai-route" "ai-model" "ai-server" "ai-image" "ai-vision" "ai-transcribe" "ai-speak" "ai-embed"];
    wrappers = map (name:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = tools;
        text = ''
          script="$HOME/.local/bin/${name}"
          if [ ! -f "$script" ]; then
            echo "Missing local-ai dotfiles: $script" >&2
            exit 1
          fi
          exec bash "$script" "$@"
        '';
      })
    commands;
    serverArgs =
      [
        "${pkgs.bash}/bin/bash"
        "${home}/.local/bin/ai-server"
        "--host"
        llama.host
        "--port"
        (toString llama.port)
        "--models-max"
        (toString llama.maxModels)
      ]
      ++ llama.extraArgs;
  in {
    imports = [self.applicationModules.agent-workspace];
    # Extend the existing named-app submodule instead of declaring a second app tree.
    options.my.apps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.unstable.llama-cpp;
            description = "llama.cpp package.";
          };
          server.enable = lib.mkEnableOption "the local llama.cpp router service";
          host = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "Router bind address.";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 8080;
            description = "Router port; keep public-dotfiles clients in sync.";
          };
          maxModels = lib.mkOption {
            type = lib.types.ints.positive;
            default = 1;
            description = "Maximum simultaneously loaded models.";
          };
          extraArgs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Additional llama-server arguments. Model presets live in public-dotfiles.";
          };
          apiKeyFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Private runtime API-key file for Gemini CLI; never a Nix store secret.";
          };
        };
      });
    };

    config = lib.mkMerge [
      {
        my.apps = {
          codex = {
            level = "system";
            packages = [pkgs.unstable.codex];
          };
          claude-code = {
            level = "system";
            packages = [pkgs.claude-code];
          };
          opencode = {
            level = "system";
            packages = [pkgs.unstable.opencode];
          };
          gemini-cli = {
            level = "system";
            packages = [pkgs.gemini-cli];
          };
          llama = {
            level = "system";
            packages = [llama.package];
          };
        };
      }
      (lib.mkIf coding {
        my.agentWiki.enable = true;
        environment.systemPackages = with pkgs; [stow (lib.lowPrio lua) taplo python3];
      })
      (lib.mkIf (coding || local) {
        my.dotfiles = {
          enable = true;
          packages = [
            {
              name = "local-ai";
              isConfig = false;
            }
          ];
        };
      })
      (lib.mkIf (apps.gemini-cli.enable && apps.gemini-cli.apiKeyFile != null) {
        environment.interactiveShellInit = ''
          if [ -r ${lib.escapeShellArg apps.gemini-cli.apiKeyFile} ]; then
            export GEMINI_API_KEY="$(cat ${lib.escapeShellArg apps.gemini-cli.apiKeyFile})"
          fi
        '';
      })
      (lib.mkIf apps.claude-code.enable {my.claudeHooks.enable = true;})
      (lib.mkIf local {
        environment.systemPackages = tools ++ wrappers;
      })
      (lib.mkIf (llama.enable && llama.server.enable) (
        if options ? launchd
        then {
          launchd.user.agents.llama-router.serviceConfig = {
            Label = "local.llama-router";
            ProgramArguments = serverArgs;
            EnvironmentVariables = {
              HOME = home;
              PATH = lib.makeBinPath tools;
            };
            RunAtLoad = true;
            KeepAlive = true;
            ThrottleInterval = 10;
            StandardOutPath = "/tmp/llama-router.log";
            StandardErrorPath = "/tmp/llama-router.error.log";
          };
        }
        else {
          systemd.user.services.llama-router = {
            description = "Local llama.cpp router";
            wantedBy = ["default.target"];
            path = tools;
            serviceConfig = {
              ExecStart = lib.escapeShellArgs serverArgs;
              Restart = "on-failure";
              RestartSec = 10;
            };
          };
        }
      ))
    ];
  };
}
