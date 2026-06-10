{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    nixos-hardware
    ;
  inherit (self)
    nixosModules
    profileModules
    ;
in
{
  flake.nixosConfigurations.hobbitton = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [ ];
  };
}
