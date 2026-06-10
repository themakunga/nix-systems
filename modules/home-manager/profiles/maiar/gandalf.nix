{
  flake.profileModules.gandalf =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkMerge mkIf;
      inherit (pkgs.stdenv) isLinux isDarwin;
      inherit (config.sops) secrets;
    in
    {
      config = mkMerge [
        {
          users.user.gandalf = {
            description = "Mithrandir sysadmin";
          };

          home-manager.users.gandalf =
            { pkgs, ... }:
            {
              programs = {
                bash.enable = true;
              };
            };
        }
        (mkIf isLinux {
          users.users.gandalf = {
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "networkmanager"
            ];
            hashedPasswordFile = secrets.password_root.path;
          };
        })
        (mkIf isDarwin {
          users.users.gandalf = {
            home = "/Users/gandalf";
          };
        })
      ];
    };
}
