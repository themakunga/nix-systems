{lib, ...}:
with lib; {
  options = {
    flake.commonModules = mkOption {
      type = types.attrsOf types.raw;
      default = {};
    };
  };
  config = {};
}
