{
  self,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (self) darwinModules homeManagerModules commonModules;
in
{
  flake.profileModules.bigboss = {
    system =
      { pkgs, ... }:
      let
        inherit (pkgs.stdenv.hostPlatform) isDarwin;
      in
      {
        imports = [
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
          description = "Nicolas Villarroel Martinez";
          extraGroups = mkIf (!isDarwin) [
            "wheel"
            "networkmanager"
            "docker"
          ];
          isNormalUser = mkIf (!isDarwin) true;
        };

      };
    darwin = {
      imports = [
        darwinModules.homebrew-config
      ];

      homebrew = {
        casks = [
          "google-chrome"
          "chromium"
          "dbeaver-community"
          "iterm2"
        ];
        masApps = { };
      };
    };
    user =
      { pkgs, ... }:
      {
        imports = [
          homeManagerModules.common
        ];

        home = {
          username = "nicolas";
        };

        programs.git = {
          enable = true;
          userName = "Nicolas Villarroel.";
          userEmail = "nicolas.villarroel@thoughtworks.com";
        };
      };
  };
}
