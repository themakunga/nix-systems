{lib, ...}: {
  flake.commonModules.keyboard = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkMerge;
    cfg = config.my.keyboard;
    inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  in {
    options.my.keyboard = {
      enable = mkEnableOption "Common keyboard config";
    };

    config = mkIf cfg.enable (mkMerge [
      (mkIf isDarwin {
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
      (mkIf isLinux {
        console.keyMap = "us";

        services.xserver.xkb = {
          layout = "us,latam";
          options = "ctrl:nocaps,grp:win_spaccce_toggle";
        };
      })
    ]);
  };
}
