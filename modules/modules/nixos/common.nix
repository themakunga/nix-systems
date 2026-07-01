{inputs, ...}: {
  flake = {
    nixosModules = {
      common = {
        imports = [
          inputs.self.commonModules.nixos-secrets
        ];

        networking.networkmanager.enable = true;

        time.timeZone = "America/Santiago";
        i18n.defaultLocale = "en_US.UTF-8";
      };
    };
  };
}
