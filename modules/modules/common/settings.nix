{self, ...}: let
  inherit (self) overlays;
in {
  flake.commonModules.settings = {
    pkgs,
    lib,
    globalConfigurations,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlaform) isDarwin isLinux;
    inherit (lib) mkIf optionals;
    inherit (globalConfigurations.stateVersion) darwin nixos;
  in {
    system.stateVersion = lib.mkMerge [
      (mkIf isLinux nixos)
      (mkIf isDarwin darwin)
    ];
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users =
          [
            "root"
            "nicolas"
          ]
          ++ optionals isLinux ["@wheel"]
          ++ optionals isDarwin ["@admin"];
      };
    };
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
      overlays = [
        overlays.unstable
      ];
    };
  };
}
