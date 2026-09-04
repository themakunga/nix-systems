# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: ollama.nix
# Path: ./modules/applications/ollama.nix
# Description: Servidor LLM local vía Ollama.
#              Soporta Linux (NixOS, systemd) y macOS (nix-darwin, launchd).
#              En macOS usa Metal automáticamente (Apple Silicon).
#              En Linux funciona CPU-only (sin aceleración por defecto).
#
# REGLAS DE EVALUACIÓN (importantes para evitar recursión infinita):
#
#   1. `lib.optionalAttrs COND { ... }` evalúa COND INMEDIATAMENTE cuando el
#      módulo retorna su valor. Si COND depende de `config` (ej: cfg.models),
#      causa recursión infinita durante el fixpoint del módulo.
#      → Usar SOLO para condiciones ESTÁTICAS (p.ej. isDarwin).
#
#   2. `lib.mkIf COND { ... }` es LAZY: el módulo system lo evalúa después de
#      resolver todo config. Seguro para condiciones que dependen de cfg.*
#      → Usar para cfg.openFirewall, cfg.models != [], etc.
#
#   3. `pkgs.stdenv.isDarwin` en el let block causa recursión porque pkgs
#      se resuelve vía _module.args.pkgs que requiere config.
#      → Usar `options ? system.darwinVersion` (check de attrset, sin config).
# =====================
{
  flake.applicationModules.ollama = {
    config,
    lib,
    pkgs,
    options,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption mkIf types;
    cfg = config.my.ollama;

    # Detección de plataforma ESTÁTICA — no depende de pkgs ni config.
    # nix-darwin declara system.darwinVersion; NixOS declara system.nixos.
    # lib.optionalAttrs es seguro con estas condiciones.
    isDarwin = options ? system.darwinVersion;
    isLinux = options ? system.nixos;
  in {
    options.my.ollama = {
      enable = mkEnableOption "Servidor LLM local con Ollama";

      host = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = ''
          Dirección de escucha de la API REST.
          Linux default: 0.0.0.0 (red local + Tailscale).
          Darwin: sobreescribir a "127.0.0.1" en el host config.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 11434;
        description = "Puerto de la API REST de Ollama.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Abrir el puerto en el firewall (solo NixOS, ignorado en Darwin).";
      };

      models = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["qwen2.5-coder:7b" "llama3.2:3b"];
        description = ''
          Modelos a descargar automáticamente tras levantar el servicio.
          Idempotente: solo hace pull si el modelo no existe.
          Los modelos persisten en ~/.ollama/models (macOS) o
          /var/lib/ollama/models (Linux).
        '';
      };
    };

    config = mkIf cfg.enable (
      lib.mkMerge [
        # ── Común: paquete CLI ───────────────────────────────────────────
        {
          environment.systemPackages = [pkgs.ollama];
        }

        # ── Linux (NixOS): systemd + firewall ───────────────────────────
        # lib.optionalAttrs isLinux es seguro: isLinux no depende de config.
        (lib.optionalAttrs isLinux (lib.mkMerge [
          {
            services.ollama = {
              enable = true;
              host = cfg.host;
              port = cfg.port;
              # Sin GPU dedicada (RPi5) — CPU only por defecto.
            };
          }
          # lib.mkIf: openFirewall depende de cfg (config) → debe ser lazy.
          (lib.mkIf cfg.openFirewall {
            networking.firewall.allowedTCPPorts = [cfg.port];
          })
          # lib.mkIf: cfg.models depende de config → debe ser lazy.
          (lib.mkIf (cfg.models != []) {
            systemd.services.ollama-pull-models = {
              description = "Pre-descarga de modelos Ollama";
              after = ["ollama.service"];
              requires = ["ollama.service"];
              wantedBy = ["multi-user.target"];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              script =
                lib.concatMapStrings (model: ''
                  if ! ${pkgs.ollama}/bin/ollama list | ${pkgs.gnugrep}/bin/grep -q "${lib.head (lib.splitString ":" model)}"; then
                    echo "Descargando ${model}..."
                    ${pkgs.ollama}/bin/ollama pull "${model}"
                  fi
                '')
                cfg.models;
            };
          })
        ]))

        # ── Darwin (macOS): launchd + activation pull ───────────────────
        # lib.optionalAttrs isDarwin es seguro: isDarwin no depende de config.
        (lib.optionalAttrs isDarwin (lib.mkMerge [
          {
            # launchd user agent: Ollama arranca al login, se mantiene vivo.
            # Apple Silicon: Metal detectado automáticamente — sin config extra.
            launchd.user.agents.ollama = {
              serviceConfig = {
                ProgramArguments = [
                  "${pkgs.ollama}/bin/ollama"
                  "serve"
                ];
                EnvironmentVariables = {
                  OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
                };
                RunAtLoad = true;
                KeepAlive = true;
                StandardOutPath = "/tmp/ollama.log";
                StandardErrorPath = "/tmp/ollama-error.log";
              };
            };
          }
          # lib.mkIf: cfg.models depende de config → debe ser lazy.
          (lib.mkIf (cfg.models != []) {
            # Activation script: espera que Ollama responda, luego hace pull.
            # Idempotente: salta si el modelo ya existe.
            system.activationScripts.ollama-pull-models.text = ''
              echo "==> ollama: verificando modelos preconfigurados..."
              for i in $(seq 1 30); do
                ${pkgs.ollama}/bin/ollama list &>/dev/null && break
                sleep 1
              done
              ${lib.concatMapStrings (model: ''
                  if ! ${pkgs.ollama}/bin/ollama list 2>/dev/null | grep -q "${lib.head (lib.splitString ":" model)}"; then
                    echo "ollama: descargando ${model}..."
                    ${pkgs.ollama}/bin/ollama pull "${model}" || true
                  else
                    echo "ollama: ${model} ya existe, skip"
                  fi
                '')
                cfg.models}
            '';
          })
        ]))
      ]
    );
  };
}
