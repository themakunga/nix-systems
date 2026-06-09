{
  self,
  inputs,
  ...
}:
let
  inherit (self)
    nixosModules
    darwinModules
    commonModules
    profileModules
    homeManagerModules
    ;
  inherit (inputs)
    nixpkgs
    nix-darwin
    ;
in
{
  flake = {
    nixosConfigurations.misty-mouintains = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit self inputs;
      };

      modules =
        (builtins.attrNames commonModules)
        ++ (builtins.attrNames profileModules)
        ++ (builtins.attrNames homeManagerModules)
        ++ (builtins.attrNames nixosModules);
    };
    darwinCondigurations.misty-mountains = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit self inputs;
      };

      modules =
        (builtins.attrNames commonModules)
        ++ (builtins.attrNames profileModules)
        ++ (builtins.attrNames homeManagerModules)
        ++ (builtins.attrNames darwinModules);
    };
  };
}
