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
        ${pkgs.switchaudio-osx}/bin/SwitchAudioSource -t input -s "HyperX SoloCast" 2>/dev/null || \
        ${pkgs.switchaudio-osx}/bin/SwitchAudioSource -t input -s "HyperX QuadCast" 2>/dev/null || true

        ${pkgs.switchaudio-osx}/bin/SwitchAudioSource -t output -s "WH-1000XM4" 2>/dev/null || true
      '';
    };
  };
}
