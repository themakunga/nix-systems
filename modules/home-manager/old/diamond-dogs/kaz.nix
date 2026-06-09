{
  self,
  lib,
  inputs,
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
      imports = [
        homeManagerModules.openconnect
      ]
      ++ optionals isDarwin [
        darwinModules.homebrew-config
        {
          homebrew = {
            brews = [ ];
            casks = [ ];
            masApps = { };
          };
        }
      ];

      home-manager.users.nicolas =
        { config, ... }:
        {
          programs = {
            openconnect.enable = true;
            git = {
              include = {
                condition = "gitdir:~/Projects/Grainger/";
                contents = {
                  user.email = "nicolas.villarroel1@kaz.com";
                  commit.gpgSign = true;
                  core.sshCommand = "ssh -i ${config.sops.secrets.grainger_ssh_key.path} -o IdentityOnly=true";
                };

              };
            };
            sops-gpg = {
              enable = true;
              keys = [
                {
                  name = "Nicolas Villarroel";
                  publicKeys = config.sops.secrets.grainger_gpg_public_key.path;
                  privateKey = config.sops.secrets.grainger_gpg_private_key.path;
                }
              ];
            };
          };
        };
    };
}
