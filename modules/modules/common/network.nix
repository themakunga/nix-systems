{
  flake.commonModules.network = {
    lib,
    pkgs,
    hostName ? "nixos-default",
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    inherit (lib) optionalAttrs;
  in {
    networking =
      {
        inherit hostName;
      }
      // optionalAttrs isDarwin {
        computerName = hostName;

        localHostName = hostName;
      };
  };
}
