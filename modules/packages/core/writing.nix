{
  flake.commonModules.core.writing = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      pandoc
    ];
  };
}
