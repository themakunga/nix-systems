{
  flake.commonModules.cloud.gcp =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        google-cloud-sdk
      ];
    };
}
