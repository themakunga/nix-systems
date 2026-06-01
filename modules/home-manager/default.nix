{
  self,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.flake = {
    homeManagerModules = mkOption {
      type = types.attrsOf types.raw;
      default = { };
      description = "Home Manager Modules, shared and single profiles for each hosto";
    };
    profileModules = mkOption {
      type = types.attrsOf types.raw;
      default = { };
      description = "Profile Management";
    };
  };
  config.flake = {
    homeManagerModules.common = {
      import = [ self.homeManagerModules.sops-config ];

      home.stateVersion = "25.11";

      programs = {
        home-manager.enable = true;
        git = {
          enable = true;
          extraConfig.init.defaultBranch = "main";
        };
      };
    };
    profileModules = { };
  };
}
