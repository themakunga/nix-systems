# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
_: {
  flake.commonModules.local-ai = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.my.localAI;
    u = pkgs.unstable;

    commands = [
      "ai"
      "ai-route"
      "ai-model"
      "ai-server"
      "ai-image"
      "ai-vision"
      "ai-transcribe"
      "ai-speak"
      "ai-embed"
    ];

    tools = [
      u.llama-cpp
      u.stable-diffusion-cpp
      u.whisper-cpp
      u.opencode

      pkgs.jq
      pkgs.curl
      pkgs.ffmpeg
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.bash
    ];

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
  in {
    options.my.localAI = {
      enable = lib.mkEnableOption "Local multimodal AI";
    };

    config = lib.mkIf cfg.enable {
      my.dotfiles = {
        enable = true;

        packages = [
          {
            name = "local-ai";
            isConfig = false;
          }
        ];
      };
      environment.variables = {
        LLAMA_ARG_CTX_SIZE = "131072";
        LLAMA_ARG_N_PARALLEL = "1";
        LLAMA_ARG_N_GPU_LAYERS = "99";
        LLAMA_ARG_FLASH_ATTN = "on";
        LLAMA_ARG_CACHE_TYPE_K = "q8_0";
        LLAMA_ARG_CACHE_TYPE_V = "q8_0";
      };
      environment.systemPackages =
        tools ++ wrappers;
    };
  };
}
