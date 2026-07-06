{lib, ...}: {
  flake.commonModules.keyboard = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkMerge;
    cfg = config.my.keyboard;
  in {
    options.my.keyboard = {
      enable = mkEnableOption "Common keyboard configuration (US/LATAM layouts and CapsLock to Ctrl)";
    };

    config = mkIf cfg.enable (mkMerge [
      (mkIf pkgs.stdenv.hostPlatform.isDarwin {
        system.keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
        };

        system.defaults = {
          NSGlobalDomain = {
            AppleLanguages = ["en-US" "es-CL"];
            AppleLocale = "en_US";
          };
          CustomUserPreferences."com.apple.HIToolbox" = {
            AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.US";
          };
        };
      })

      (mkIf pkgs.stdenv.hostPlatform.isLinux {
        console.keyMap = "us";

        services.xserver.xkb = {
          layout = "us,latam";
          options = "ctrl:nocaps,grp:win_space_toggle";
        };
      })
    ]);
  };
}
