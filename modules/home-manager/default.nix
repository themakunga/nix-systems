{
  self,
  lib,
  ...
}:
with lib; {
  options = {
    flake = {
      homeManagerModules = mkOption {
        type = types.attrsOf types.raw;
        default = {};
      };
    };
  };
  config = {
    flake.homeModules.common = {
      import = [self.homeManagerModules.sops-config];

      home.stateVersion = "25.11";

      programs = {
        home-manager.enable = true;
        git = {
          enable = true;
          extraConfig.init.defaultBranch = "main";
        };
      };
    };
  };
}
