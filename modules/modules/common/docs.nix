{
  self,
  lib,
  ...
}: {
  flake.commonModules.docsBuilder = pkgs: modulesToDocument: let
    dummyOS = {
      config._module.check = false;
    };

    eval = pkgs.lib.evalModules {
      modules = modulesToDocument ++ [dummyOS];
      specialArgs = {
        inherit pkgs;
      };
    };

    optionsDoc = pkgs.nixosOptionsDoc {
      inherit (eval) options;
      warningsAreErrors = false;
    };
  in
    pkgs.runCommand "generate-flake-docs" {} ''
      cp ${optionsDoc.optionsCommonMark} $out
    '';

  perSystem = {pkgs, ...}: {
    packages.docs = let
      extractModules = x:
        if lib.isFunction x
        then [x]
        else if lib.isAttrs x
        then
          if x ? options || x ? config || x ? imports
          then [x]
          else if x ? type && x.type == "derivation"
          then []
          else if x ? outPath
          then []
          else lib.concatMap extractModules (lib.attrValues x)
        else [];

      appModules = extractModules (self.applicationModules or {});
    in
      self.commonModules.docsBuilder pkgs appModules;
  };
}
