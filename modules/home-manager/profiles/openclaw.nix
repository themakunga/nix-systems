{
  self,
  lib,
  ...
}:
let
  inherit (lib) mkIf optionals;
  inherit (self)
    darwinModules
    homeManagerModules
    commonModules
    ;
in
{
  flake.profileModules.kaz =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in
    {
      imports =
        [ ]
        ++ optionals isDarwin [
          darwinModules.homebrew-config
          ({
            homebrew = {
              brews = [ ];
              casks = [ ];
              masApps = { };
            };
          })
        ];

      home-manager.users.nicolas = {
        programs = {
          git = { };
          sops-gpg = { };
        };
      };
    };
}
