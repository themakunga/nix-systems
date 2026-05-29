{
  flake.commonModules.dev-go = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      go
      gopls
      delve
      golangci-lint
      gotools
      gomodifytags
      air
    ];
  };
}
