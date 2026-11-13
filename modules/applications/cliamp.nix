# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.cliamp = mkAppModule "cliamp" "Enable cliamp terminal music player (Spotify, YT Music, podcasts, radio)" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.unstable.cliamp];
    };
    sysConfig = {
      config,
      pkgs,
      ...
    }: let
      user = config.system.primaryUser or "nicolas";
      userHome =
        if pkgs.stdenv.isDarwin
        then "/Users/${user}"
        else "/home/${user}";
      setupScript = ''
        CLIAMP_DIR="${userHome}/.config/cliamp"
        CLIAMP_SOURCE="${userHome}/.public-dotfiles/cliamp"
        mkdir -p "$CLIAMP_DIR"
        chown ${user} "$CLIAMP_DIR"
        # cliamp replaces these files atomically; seed once instead of linking or overwriting.
        for file in config.toml podcast_subscriptions.json radio_favorites.toml radios.toml; do
          if [ -f "$CLIAMP_SOURCE/$file" ] && [ ! -e "$CLIAMP_DIR/$file" ] && [ ! -L "$CLIAMP_DIR/$file" ]; then
            ${pkgs.coreutils}/bin/install -m 600 -o ${user} "$CLIAMP_SOURCE/$file" "$CLIAMP_DIR/$file"
          fi
        done
      '';
    in {
      my.sharedPlain.cliamp = {
        source = "cliamp/config.toml";
        path = "${userHome}/.config/cliamp/config.toml";
        mode = "0600";
      };
      system.activationScripts =
        if pkgs.stdenv.isDarwin
        then {postActivation.text = setupScript;}
        else {
          seedCliamp = {
            deps = ["users" "copySharedPlain"];
            text = setupScript;
          };
        };
    };
  };
}
