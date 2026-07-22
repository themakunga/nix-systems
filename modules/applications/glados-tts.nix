# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.glados-tts = mkAppModule "glados-tts" "Enable GLaDOS TTS CLI tool" {
    meta = {pkgs, ...}: let
      gladosScript = pkgs.writeShellScriptBin "glados-say" ''
        set -e
        MODEL_DIR="$HOME/.local/share/glados-tts"
        MODEL_FILE="$MODEL_DIR/glados.onnx"
        CONFIG_FILE="$MODEL_DIR/glados.onnx.json"

        mkdir -p "$MODEL_DIR"

        if [ ! -f "$MODEL_FILE" ]; then
          echo "Downloading GLaDOS model..."
          ${pkgs.curl}/bin/curl -sL "https://huggingface.co/DavesArmoury/GLaDOS_TTS/resolve/main/glados.onnx" -o "$MODEL_FILE"
        fi

        if [ ! -f "$CONFIG_FILE" ]; then
          echo "Downloading GLaDOS config..."
          ${pkgs.curl}/bin/curl -sL "https://huggingface.co/DavesArmoury/GLaDOS_TTS/resolve/main/glados.onnx.json" -o "$CONFIG_FILE"
        fi

        TEXT="''${1:-$(cat)}"

        # We strip some basic markdown that piper might mispronounce
        CLEAN_TEXT=$(echo "$TEXT" | sed -E 's/```.*```//g' | sed 's/`//g' | sed 's/\*//g' | sed 's/#//g')

        if [ -z "$CLEAN_TEXT" ]; then
            exit 0
        fi

        PLAY_CMD="afplay"
        if ! command -v afplay &> /dev/null; then
          PLAY_CMD="${pkgs.mpv}/bin/mpv"
        fi

        TEMP_WAV=$(mktemp)
        echo "$CLEAN_TEXT" | ${pkgs.piper-tts}/bin/piper --model "$MODEL_FILE" --output_file "$TEMP_WAV" >/dev/null 2>&1
        $PLAY_CMD "$TEMP_WAV"
        rm -f "$TEMP_WAV"
      '';
    in {
      level = "system";
      packages = [
        gladosScript
        pkgs.piper-tts
      ];
    };
  };
}
