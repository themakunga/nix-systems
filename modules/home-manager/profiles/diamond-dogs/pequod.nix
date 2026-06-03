{
  self,
  lib,
  ...
}:
let
  inherit (lib) mkIf optionals;
  inherit (self) darwinModules homeManagerModules commonModules;
in
{
  flake.profileModules.frank =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in
    {
      imports =
        [ ]
        ++ optionals isDarwin [
          {
            homebrew = {
              brews = [ ];
              casks = [ ];
              masApps = { };
            };
          }
        ];

      home-manager.user.nicolas = {
        programs = {
          git = { };
          sops-gpg = { };

        };
      };
    };

}
