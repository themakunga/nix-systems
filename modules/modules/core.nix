{ inputs, ... }:
{
  flake = {
    commonModules = {
      home-manager-conf =
        { pkgs, ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      nix-settings =
        { pkgs, ... }:
        {
          system.stateVersion = 25.11;
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
            inputs.self.overlays.unstable
          ];
        };
    };
  };
}
