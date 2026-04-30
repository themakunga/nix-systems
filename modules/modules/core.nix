{ inputs, ... }:
{
  flake = {
    commonModules = {
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
