# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# tuifeed — terminal RSS/Atom reader with a panel UI.
# Config lives in ~/.config/tuifeed/config.toml (XDG).
# On Darwin tuifeed resolves to ~/Library/Application Support/tuifeed/;
# the activation script symlinks that directory to the XDG path.
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.tuifeed = mkAppModule "tuifeed" "Enable tuifeed terminal RSS/Atom reader" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.tuifeed];
    };
    sysConfig = {
      config,
      lib,
      pkgs,
      ...
    }: let
      user = config.system.primaryUser or "nicolas";
      userHome =
        if pkgs.stdenv.isDarwin
        then "/Users/${user}"
        else "/home/${user}";
      xdgConfig = "${userHome}/.config/tuifeed";
      macAppSupport = "${userHome}/Library/Application Support/tuifeed";
    in
      lib.mkMerge [
        {
          my.dotfiles.packages = [
            {
              name = "tuifeed";
              isConfig = true;
            }
          ];
        }
        (lib.mkIf pkgs.stdenv.isDarwin {
          system.activationScripts.postActivation.text = lib.mkAfter ''
            # tuifeed on macOS resolves ~/Library/Application Support/tuifeed/
            # Symlink it to the XDG path managed by stow.
            mkdir -p "${xdgConfig}"
            if [ ! -L "${macAppSupport}" ]; then
              rm -rf "${macAppSupport}"
              ln -sf "${xdgConfig}" "${macAppSupport}"
            fi
          '';
        })
      ];
  };
}
