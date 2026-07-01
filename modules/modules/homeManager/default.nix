{
  inputs,
  globals,
  ...
}: let
  inherit (globals) stateVersion;
in {
  flake.homeManagerModules.common = {
    imports = [
      inputs.self.commonModules.home-secrets
    ];

    home = {
      stateVersion = stateVersion.home-manager;
      enableNixpkgsReleaseCheck = false;
    };

    programs = {
      home-manager.enable = true;
      git = {
        enable = true;
        settings.init.defaultBranch = "main";
      };
    };
  };
}
