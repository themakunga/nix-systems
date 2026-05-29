{
  flake.commonModules.dev-misc = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      opam
    ];
  };
}
