{inputs, ...}: {
  flake = {
    overlays = {
      unstable = {system, ...} {
        unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
  };

  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [inputs.self.overlays.unstable];
    };
  };
}
