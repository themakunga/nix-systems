# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: applicationModules.agents
# =========================================================
{
  flake.applicationModules.agents = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit
      (lib)
      mkEnableOption
      mkOption
      types
      mkIf
      mkMerge
      optional
      optionalAttrs
      ;
    cfg = config.my.agents;
    user = config.system.primaryUser or "nicolas";
  in {
    options.my.agents = {
      claude = {
        enable = mkEnableOption "Claude Code CLI";
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
        };
        useDotfiles = mkOption {
          type = types.bool;
          default = false;
        };
        useSecrets = mkOption {
          type = types.bool;
          default = false;
        };
      };

      codeen = {
        enable = mkEnableOption "Codeen CLI";
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
        };
        useDotfiles = mkOption {
          type = types.bool;
          default = false;
        };
        useSecrets = mkOption {
          type = types.bool;
          default = false;
        };
      };

      zeroclaw = {
        enable = mkEnableOption "ZeroClaw Agent";
        package = mkOption {
          type = types.nullOr types.package;
          default = pkgs.zeroclaw;
        };
        useDotfiles = mkOption {
          type = types.bool;
          default = false;
        };
        useSecrets = mkOption {
          type = types.bool;
          default = false;
        };
        cores = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Número de cores asignados a ZeroClaw";
        };
        memory = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Límite de memoria para ZeroClaw (ej. '8G', '16G')";
        };
        extraEnv = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = "Variables de entorno adicionales para configuración avanzada.";
        };
      };

      ollama = {
        enable = mkEnableOption "Ollama Local LLM";
        package = mkOption {
          type = types.nullOr types.package;
          default = pkgs.ollama;
        };
        useDotfiles = mkOption {
          type = types.bool;
          default = false;
        };
        useSecrets = mkOption {
          type = types.bool;
          default = false;
        };
        cores = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "Hilos de CPU asignados a Ollama (OLLAMA_OMP_NUM_THREADS)";
        };
        memory = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Límite de VRAM/RAM para Ollama (OLLAMA_MAX_VRAM, ej. '8G')";
        };
        extraEnv = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = "Otras variables (ej. OLLAMA_KEEP_ALIVE)";
        };
      };
    };

    config = mkMerge [
      # ===============================
      # 🤖 CLAUDE
      # ===============================
      (mkIf cfg.claude.enable {
        environment = {
          systemPackages = optional (cfg.claude.package != null) cfg.claude.package;
          interactiveShellInit = mkIf cfg.claude.useSecrets ''
            if [ -f "${config.sops.secrets."agents/claude/env".path}" ]; then
              source "${config.sops.secrets."agents/claude/env".path}"
            fi
          '';
        };
        my.dotfiles.packages = mkIf cfg.claude.useDotfiles [
          {
            name = "claude";
            isConfig = true;
          }
        ];
        sops.secrets."agents/claude/env" = mkIf cfg.claude.useSecrets {owner = user;};
      })

      # ===============================
      # 🤖 CODEEN
      # ===============================
      (mkIf cfg.codeen.enable {
        environment = {
          systemPackages = optional (cfg.codeen.package != null) cfg.codeen.package;
          interactiveShellInit = mkIf cfg.codeen.useSecrets ''
            if [ -f "${config.sops.secrets."agents/codeen/env".path}" ]; then
              source "${config.sops.secrets."agents/codeen/env".path}"
            fi
          '';
        };
        my.dotfiles.packages = mkIf cfg.codeen.useDotfiles [
          {
            name = "codeen";
            isConfig = true;
          }
        ];
        sops.secrets."agents/codeen/env" = mkIf cfg.codeen.useSecrets {owner = user;};
      })

      # ===============================
      # 🤖 ZEROCLAW
      # ===============================
      (mkIf cfg.zeroclaw.enable {
        environment = {
          systemPackages = optional (cfg.zeroclaw.package != null) cfg.zeroclaw.package;
          interactiveShellInit = mkIf cfg.zeroclaw.useSecrets ''
            if [ -f "${config.sops.secrets."agents/zeroclaw/env".path}" ]; then
              source "${config.sops.secrets."agents/zeroclaw/env".path}"
            fi
          '';
          variables =
            (optionalAttrs (cfg.zeroclaw.cores != null) {ZEROCLAW_CORES = toString cfg.zeroclaw.cores;})
            // (optionalAttrs (cfg.zeroclaw.memory != null) {ZEROCLAW_MEMORY = cfg.zeroclaw.memory;})
            // cfg.zeroclaw.extraEnv;
        };
        my.dotfiles.packages = mkIf cfg.zeroclaw.useDotfiles [
          {
            name = "zeroclaw";
            isConfig = true;
          }
        ];
        sops.secrets."agents/zeroclaw/env" = mkIf cfg.zeroclaw.useSecrets {owner = user;};
      })

      # ===============================
      # 🦙 OLLAMA
      # ===============================
      (mkIf cfg.ollama.enable {
        environment = {
          systemPackages = optional (cfg.ollama.package != null) cfg.ollama.package;
          interactiveShellInit = mkIf cfg.ollama.useSecrets ''
            if [ -f "${config.sops.secrets."agents/ollama/env".path}" ]; then
              source "${config.sops.secrets."agents/ollama/env".path}"
            fi
          '';
          variables =
            (optionalAttrs (cfg.ollama.cores != null) {OLLAMA_OMP_NUM_THREADS = toString cfg.ollama.cores;})
            // (optionalAttrs (cfg.ollama.memory != null) {OLLAMA_MAX_VRAM = cfg.ollama.memory;})
            // cfg.ollama.extraEnv;
        };
        my.dotfiles.packages = mkIf cfg.ollama.useDotfiles [
          {
            name = "ollama";
            isConfig = true;
          }
        ];
        sops.secrets."agents/ollama/env" = mkIf cfg.ollama.useSecrets {owner = user;};
        launchd.user.agents.ollama = mkIf pkgs.stdenv.hostPlatform.isDarwin {
          serviceConfig = {
            ProgramArguments = [
              "${cfg.ollama.package}/bin/ollama"
              "serve"
            ];
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/tmp/ollama.out";
            StandardErrorPath = "/tmp/ollama.err";
            # Le inyectamos los recursos directamente al motor del daemon
            EnvironmentVariables =
              (optionalAttrs (cfg.ollama.cores != null) {OLLAMA_OMP_NUM_THREADS = toString cfg.ollama.cores;})
              // (optionalAttrs (cfg.ollama.memory != null) {OLLAMA_MAX_VRAM = cfg.ollama.memory;})
              // cfg.ollama.extraEnv;
          };
        };
      })
    ];
  };
}
