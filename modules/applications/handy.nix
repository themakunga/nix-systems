# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.handy = self.lib.mkAppModule "handy" "Enable offline English and Spanish dictation" {
    meta = {
      pkgs,
      lib,
      ...
    }: {
      level = "system";
      packages = lib.optionals pkgs.stdenv.isLinux [pkgs.unstable.handy pkgs.wtype pkgs.wl-clipboard];
      casks = lib.optionals pkgs.stdenv.isDarwin ["handy"];
    };
    sysConfig = {
      config,
      lib,
      pkgs,
      ...
    }: let
      isDarwin = pkgs.stdenv.isDarwin;
      dotfiles = config.my.dotfiles;
      targets =
        [
          {
            user = dotfiles.user;
            home = dotfiles.home;
          }
        ]
        ++ dotfiles.additionalUsers;
      variant =
        if isDarwin
        then "medium"
        else "small";
      filename = "whisper-${variant}-Q8_0.gguf";
      revision =
        if isDarwin
        then "ec78f06fded51aa82cde751678b78f76f78c8b7f"
        else "c0214bd34be9296695486f838e0142f900803159";
      model = pkgs.fetchurl {
        url = "https://huggingface.co/handy-computer/whisper-${variant}-gguf/resolve/${revision}/${filename}";
        sha256 =
          if isDarwin
          then "09e6a65e7de377aa5b10bae24608bc6f8ca2ed04b3993ef10d4a02bcd9a82adf"
          else "9b9c8811bbcc82a7766f0fb0925614bdacb0923b2cc630daeac17108b655b860";
      };
      seed = target: let
        home =
          if target.home != null
          then target.home
          else
            (
              if isDarwin
              then "/Users/${target.user}"
              else "/home/${target.user}"
            );
        directory =
          "${home}/"
          + (
            if isDarwin
            then "Library/Application Support/com.pais.handy"
            else ".local/share/com.pais.handy"
          );
        platform =
          if isDarwin
          then "macos"
          else "linux";
        commands = ''
          set -eu
          umask 077
          mkdir -p "${directory}/models"
          # Handy rewrites its store; seed once and preserve local settings.
          if [ ! -e "${directory}/settings_store.json" ] && [ ! -L "${directory}/settings_store.json" ]; then
            cp "${home}/.public-dotfiles/handy/${platform}-settings.json" "${directory}/settings_store.json"
          fi
          if [ ! -e "${directory}/models/${filename}" ] && [ ! -L "${directory}/models/${filename}" ]; then
            ln -s ${model} "${directory}/models/${filename}"
          fi
        '';
        sudo =
          if isDarwin
          then "/usr/bin/sudo"
          else "/run/wrappers/bin/sudo";
      in ''
        ${sudo} -H -u ${lib.escapeShellArg target.user} ${pkgs.runtimeShell} -c ${lib.escapeShellArg commands}
      '';
      setup = lib.concatMapStringsSep "\n" seed targets;
    in {
      system.activationScripts =
        if isDarwin
        then {
          postActivation.text = lib.mkAfter setup;
        }
        else {
          seedHandy = {
            deps = ["users" "stowDotfiles"] ++ map (target: "stowDotfiles-${target.user}") dotfiles.additionalUsers;
            text = setup;
          };
        };
    };
  };
}
