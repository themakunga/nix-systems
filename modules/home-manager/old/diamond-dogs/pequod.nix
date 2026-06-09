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
  flake.profileModules.pequod =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in
    {
      imports =
        [ ]
        ++ optionals isDarwin [
          darwinModules.homebnrew-config
          {
            homebrew = {
              brews = [ ];
              casks = [ ];
              masApps = { };
            };
          }
        ];

      home-manager.user.nicolas =
        { config, ... }:
        {
          programs = {
            git = {
              include = {
                condition = "gitdir:~/Projects/Thougthworks/";
                contents = {
                  user.email = "nicolas.villarroel@thougthworks.com";
                  commit.gpgSign = true;
                  core.sshCommand = "ssh -i
                  ${config.sops.secrets.thougthworks_ssh_key.path} -o IdentityOnly=true";
                };
              };
            };
            sops-gpg = {
              enable = true;
              keys = [
                {
                  name = "Nicolas Villarroel M";
                  publicKey = config.sops.secrets.thougthworks_gpg_public_key;
                  privateKey = config.sops.secrets.thougthworks_gpg_private_key;
                }
              ];
            };

          };
        };
    };

}
