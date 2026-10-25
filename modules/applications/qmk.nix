# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.qmk = mkAppModule "qmk" "Enable QMK firmware toolchain and repository" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [
        pkgs.qmk
        pkgs.avrdude
        pkgs.dfu-util
        pkgs.gcc-arm-embedded
        pkgs.pkgsCross.avr.buildPackages.gcc
      ];
    };
    sysConfig = {
      config,
      lib,
      pkgs,
      ...
    }: let
      user = config.system.primaryUser or "nicolas";
      isDarwin = pkgs.stdenv.isDarwin;
      userHome =
        if isDarwin
        then "/Users/${user}"
        else "/home/${user}";
      qmkHome = "${userHome}/qmk_firmware";
    in {
      system.activationScripts =
        if isDarwin
        then {
          postActivation.text = lib.mkAfter ''
            if [ ! -d "${qmkHome}" ]; then
              echo "QMK: clonando qmk_firmware en ${qmkHome}..."
              sudo -u ${user} ${pkgs.git}/bin/git clone --recurse-submodules \
                https://github.com/qmk/qmk_firmware.git "${qmkHome}"
              sudo -u ${user} ${pkgs.qmk}/bin/qmk config user.qmk_home="${qmkHome}"
            fi
          '';
        }
        else {
          qmk-setup = {
            text = ''
              if [ ! -d "${qmkHome}" ]; then
                echo "QMK: clonando qmk_firmware en ${qmkHome}..."
                sudo -u ${user} ${pkgs.git}/bin/git clone --recurse-submodules \
                  https://github.com/qmk/qmk_firmware.git "${qmkHome}"
                sudo -u ${user} ${pkgs.qmk}/bin/qmk config user.qmk_home="${qmkHome}"
              fi
            '';
          };
        };
    };
  };
}
