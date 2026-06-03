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
    ;
in
{
  flake.nixosConfigurations.lsp-dummy-host = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };
    modules = [
      nixosModules
      darwinModules
      commonModules
      profileModules
      homeManagerModules
    ];
  };
}
