{
  self,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self)
    darwinModules
    homeManagerModules
    commonModules
    ;
in
{
  flake.profileModules.bigboss =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in
    {
      imports = [
        darwinModules.common
        darwinModules.homebrew-config
        homeManagerModules.common
        ## Packages
        commonModules.home-manager-config
        commonModules.editor
        commonModules.cloud-aws
        commonModules.cloud-observability
        commonModules.containers-rancher
        commonModules.dev-core
        commonModules.dev-go
        commonModules.dev-iac
        commonModules.dev-lua
        commonModules.dev-nix
        commonModules.dev-nodejs
        commonModules.dev-python
        commonModules.dev-rust

      ];

      users.users.nicolas = {
        description = "Nicolas Villarroel M";
        extraGroups = mkIf (!isDarwin) [
          "wheel"
          "networkmanager"
          "docker"
        ];
        isNormalUser = mkIf (!isDarwin) true;
      };

      homebrew = {
        enable = true;
        casks = [
          "google-chrome"
          "chromium"
          "dbeaver"
          "iterm2"
        ];
        masApps = { };

      };

      programs.git = {
        enable = true;
        userName = "Nicolas Villarroel";
        userEmail = "nicolas.villarroel@thoughtworks.com";
      };
    };

}
