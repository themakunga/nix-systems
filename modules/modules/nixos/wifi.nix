{
  flake.nixosModules.wifi = {config, ...}: {
    networking.wireless = {
      enable = true;

      secretFile = config.sops.secrets."wifi/credentials".path;

      networks = {
        "AMANDA" = {
          psk = "ext:password_home";
          priority = 10;
        };
        "42Devs" = {
          psk = "ext:password_42devs";
          priority = 5;
        };
        "Nicolas`s iPhone" = {
          psk = "ext:password_iphone";
          priority = 1;
        };
      };
    };
    sops.secrets."wifi/credentials" = {
      restartUnits = ["wpa_supplicant.service"];
    };
  };
}
