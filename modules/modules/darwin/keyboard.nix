{lib, ...}: {
  flake.darwinModules.keyboard = {config, ...}: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.keyboard;
  in {
    options.my.keyboard = {
      enable = mkEnableOption "macOS Keyboard configuration";
    };

    config = mkIf cfg.enable {
      system = {
        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
        };
        defaults.NSGlobalDomain = {
          AppleLanguages = ["en-US" "es-CL"];
          AppleLocale = "en_US";
        };
      };
    };
  };
}
