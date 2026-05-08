{
  inputs,
  system,
}: {
  flake = {
    overlays = {
      unstable = {
        unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
  };

  perSystem = {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [inputs.self.overlays.unstable];
    };
  };
}
