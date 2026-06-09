{
  flake.commonModules.dev.rust =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        cargo
        rustc
        rust-analyzer
        rustfmt
        clippy
        cargo-watch
      ];
    };
}
