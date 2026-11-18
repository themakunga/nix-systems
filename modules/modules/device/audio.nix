# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: deviceModules.audio
# =========================================================
{
  flake.deviceModules.audio = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.devices.audio;
  in {
    options.my.devices.audio = {
      enable = mkEnableOption "Habilitar pila de audio optimizada";
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        switchaudio-osx
      ];

      system.activationScripts.postActivation.text = lib.mkAfter ''
        echo "=> Configurando perfiles de audio en macOS..."
        configure_audio_device() {
          audio_type="$1"
          audio_name="$2"
          if audio_devices=$(${pkgs.switchaudio-osx}/bin/SwitchAudioSource -a -t "$audio_type" 2>&1); then
            if printf '%s\n' "$audio_devices" | /usr/bin/grep -Fxq "$audio_name"; then
              if audio_output=$(${pkgs.switchaudio-osx}/bin/SwitchAudioSource -t "$audio_type" -s "$audio_name" 2>&1); then
                echo "  OK: $audio_name"
              else
                printf '%s\n' "$audio_output" >&2
              fi
            fi
          else
            printf '%s\n' "$audio_devices" >&2
          fi
          return 0
        }
        configure_audio_device input "HyperX QuadCast"
        configure_audio_device output "head radio"
      '';
    };
  };
}
