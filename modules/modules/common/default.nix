{ inputs, self, ... }:
{
  flake = {
    commonModules = {
      home-manager-conf =
        { pkgs, ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      state-version =
        { pkgs, lib, ... }:
        with lib;
        mkMerge [
          (mkIf pkgs.stdenv.hostPlatform.isLinux {
            system.stateVersion = "25.11";
          })
          (mkIf pkgs.stdenv.hostPlatform.isDarwin {
            system.stateVersion = 6;
          })
        ];

      nix-settings =
        { pkgs, ... }:
        {
          system.stateVersion = "25.11";

          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users = [
              "@wheel"
              "root"
            ];
          };
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            self.overlays.unstable
          ];
        };
    };
  };
}
