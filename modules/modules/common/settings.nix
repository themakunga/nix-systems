{self, ...}: {
  flake.commonModules.settings = {
    pkgs,
    lib,
    ...
  }: {
    system.stateVersion = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux "25.11")
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 6)
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
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux ["@wheel"]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin ["@admin"];
      };
    };
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
      overlays = [
        self.overlays.unstable
      ];
    };
  };
}
