# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.glados-tts = self.lib.mkAppModule "glados-tts" "Local GLaDOS speech for coding agents" {
    meta = {pkgs, ...}: let
      piper = pkgs.piper-tts.override {
        withTrain = false;
        withHTTP = false;
        withAlignment = false;
      };
      source = "https://huggingface.co/DavesArmoury/GLaDOS_TTS/resolve/b64622ad52f15804249f7f08a4c268b5e82c6969";
      model = pkgs.fetchurl {
        url = "${source}/glados_piper_medium.onnx";
        hash = "sha256-s1oH+m/HiOxK1jfsmLdNZvBuZku7Q2a0A10d6qwzCNM=";
      };
      modelConfig = pkgs.fetchurl {
        url = "${source}/glados_piper_medium.onnx.json";
        hash = "sha256-d6EDN3yXHoe/rGqDm+sN6VQz84rPH7ksIB3Nxyhi9CI=";
      };
      # Piper 1.4 loads <model>.json beside the model; it has no --config flag.
      voice = pkgs.linkFarm "glados-voice" [
        {
          name = "glados.onnx";
          path = model;
        }
        {
          name = "glados.onnx.json";
          path = modelConfig;
        }
      ];
      player =
        if pkgs.stdenv.isDarwin
        then "/usr/bin/afplay"
        else "${pkgs.mpv}/bin/mpv";
      command = mode:
        pkgs.writeShellScriptBin "glados-${mode}" ''
          export GLADOS_PIPER=${piper}/bin/piper
          export GLADOS_MODEL=${voice}/glados.onnx
          export GLADOS_PLAYER=${player}
          exec ${pkgs.python3}/bin/python3 ${./glados-tts/speech.py} ${mode} "$@"
        '';
    in {
      level = "system";
      packages = [(command "say") (command "hook")];
    };

    sysConfig = {
      config,
      lib,
      pkgs,
      ...
    }:
      lib.mkIf pkgs.stdenv.isDarwin {
        system.activationScripts.postActivation.text = lib.mkAfter ''
          echo "=> Configuring GLaDOS speech for Codex and Claude Code..."
          /usr/bin/sudo -H -u ${lib.escapeShellArg config.system.primaryUser} ${pkgs.python3}/bin/python3 ${./glados-tts/install-hooks.py} /run/current-system/sw/bin
        '';
      };
  };
}
