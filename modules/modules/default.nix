{ lib, ... }:
with lib;
{
  options = {
    flake = {
      commonModules = mkOption {
        type = types.attrsOf types.raw;
        default = { };
      };
      darwinModules = mkOption {
        type = types.attrsOf types.raw;
        default = { };
      };
      darwinConfigurations = mkOption {
        type = types.attrsOf types.raw;
        default = { };
      };
      rpiModules = mkOption {
        type = types.attrsOf types.raw;
        default = { };
      };
    };
  };
  config = { };
}
