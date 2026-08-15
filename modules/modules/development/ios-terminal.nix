{
  flake.developmentModules.ios-terminal = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf optionals;
    cfg = config.my.development.ios-terminal;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;

    iosSimHelper = pkgs.writeShellScriptBin "ios-sim" ''
      #!/usr/bin/env bash
      CMD=$1
      DEVICE="''${2:-iPhone 15}" # Por defecto usa iPhone 15 si no especificas uno

      if [ -z "$CMD" ]; then
        echo "🍎 iOS Simulator CLI Helper"
        echo "---------------------------------"
        echo "Uso: ios-sim [comando] [dispositivo]"
        echo ""
        echo "Comandos:"
        echo "  list      -> Muestra los simuladores instalados y disponibles"
        echo "  boot      -> Enciende un simulador (ej. ios-sim boot \"iPhone 15 Pro\")"
        echo "  shutdown  -> Apaga todos los simuladores encendidos"
        echo "  open      -> Abre la aplicación gráfica del Simulador"
        exit 1
      fi

      case $CMD in
        list)
          echo "=> Simuladores Disponibles:"
          xcrun simctl list devices available
          ;;
        boot)
          echo "=> Encendiendo simulador: $DEVICE..."
          # Enciende la máquina virtual en el fondo
          xcrun simctl boot "$DEVICE" 2>/dev/null || echo "El simulador ya está encendido o no se encontró el nombre."
          # Lanza la interfaz gráfica para que puedas verlo
          open -a Simulator
          ;;
        shutdown)
          echo "=> Apagando todos los simuladores..."
          xcrun simctl shutdown all
          ;;
        open)
          open -a Simulator
          ;;
        *)
          echo "❌ Comando no reconocido."
          ;;
      esac
    '';
  in {
    options.my.development.ios-terminal = {
      enable = mkEnableOption "iOS terminal Development Toolkit (Tuist,
      xcbeautify, simctl helpers)";
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        tuist
        xcbeautify
        ios-deploy
        iosSimHelper
        xcodes
      ];

      warnings =
        if (cfg.enable && !isDarwin)
        then ["🚨 El desarrollo de iOS nativo requiere macOS. El módulo ios-terminal no funcionará correctamente en Linux."]
        else [];
    };
  };
}
