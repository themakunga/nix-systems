{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options = {
    flake = {
      commonModules = mkOption {
        description = "Shared Modules accross differents systems";
        type = types.attrsOf types.raw;
        default = { };
      };
      darwinModules = mkOption {
        description = "Darwin Modules to use with Apple Sillicon products";
        type = types.attrsOf types.raw;
        default = { };
      };
      darwinConfigurations = mkOption {
        description = "Darwin main configurations";
        type = types.attrsOf types.raw;
        default = { };
      };
      rpiModules = mkOption {
        description = "Nixos aarch64-linux focused modules, to use exclusivelly
          with raspberry pi";
        type = types.attrsOf types.raw;
        default = { };
      };
      homeManagerModules = mkOption {
        description = "Home Manager Modules, shared and single profiles for each hosto";
        type = types.attrsOf types.raw;
        default = { };
      };
      profileModules = mkOption {
        description = "Profile Management";
        type = types.attrsOf types.raw;
        default = { };
      };
      userModules = mkOption {
        description = "User creation Modules";
        type = types.attrsOf types.raw;
        default = { };
      };
    };
  };
  config = { };
}
