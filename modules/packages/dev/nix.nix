{
  flake.commonModules.dev.nix = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      alejandra
      deadnix
      nil
      nix-tree
      nix-update
      statix
    ];
  };
}
