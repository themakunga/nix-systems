{
  flake.commonModules.arch = {
    nixos = {
      rpi = {
        nixpkgs.hostPlatform = "aarch64-linux";
      };
      x64 = {
        nixpkgs.hostPlatform = "x86_64-linux";
      };
    };
    darwin = {
      silicon = {
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
      intel = {
        nixpkgs.hostPlatform = "x86_64-darwin";
      };
    };
  };
}
