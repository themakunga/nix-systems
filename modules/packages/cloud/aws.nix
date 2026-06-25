{
  flake.commonModules.cloud.aws = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      aws-vault
      awscli2
      granted
    ];
  };
}
