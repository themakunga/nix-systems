{
  flake.commonModules.cloud-observability = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ctop
      stern
      lens
    ];
  };
}
