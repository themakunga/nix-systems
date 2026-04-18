{ inputs, system, ... }:
final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config = final.config;  # inherit allowUnfree, etc. from stable
  };
}
