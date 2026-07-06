{lib, ...}: {
  flake.commonModules.keyboard = {config, ...}: let
    inherit (lib) mkEnableOption mkIf mkMerge optionalAttrs;
    cfg = config.my.keyboard;
    isLinux = config ? system.nixos;
    isDarwin = config ? system.darwinLabel;
  in {
    options.my.keyboard = {
      enable = mkEnableOption "Common keyboard config";
    };

    config = mkIf cfg.enable (mkMerge [
      (optionalAttrs isDarwin {
        system = {
          keyboard = {
            enableKeyMapping = true;
            remapCapsLockToControl = true;
          };
          default.NSGlobalDomain = {
            AppleLanguages = ["en-US" "es-CL"];
            AppleLocale = "en_US";
          };
        };
      })
      (optionalAttrs isLinux {
        console.keyMap = "us";

        services.xserver.xkb = {
          layout = "us,latam";
          options = "ctrl:nocaps,grp:win_spaccce_toggle";
        };
      })
    ]);
  };
}
