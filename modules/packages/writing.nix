{
  flake.commonModules.writing = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      pandoc
    ];
  };
}
