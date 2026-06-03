{ self, ... }:
{
  flake.commonModules.sops-gpg =
    { pkgs, lib, ... }:
    let
      inherit (lib)
        mkEnableOption
        mkOption
        types
        mkIf
        concatMapStringsSep
        ;
    in
    {
      home-manager.sharedModules = [
        (
          {
            config,
            pkgs,
            lib,
            ...
          }:
          let
            cfg = config.programs.sops-gpg;
          in
          {
            options.programs.sops-gpg = {
              enable = mkEnableOption "Declarative GPG key importer";
              keys = mkOption {
                description = "Private and Public GPG keys";
                default = [ ];
                type = types.listOf (
                  types.submodule {
                    options = {
                      name = mkOption { type = types.str; };
                      publicKey = mkOption { type = types.str; };
                      privateKey = mkOption { type = types.str; };
                    };
                  }
                );
              };
            };
            config = mkIf cfg.enable {
              home.activation.importSopsGpg = config.lib.home-manager.dag.entryAfter [ "writeBoundary" ] (
                concatMapStringsSep "\n" (key: ''
                      if [ -f "${key.publicKey}" ]; then
                    echo "--> [GPG] Importando llave pública para: ${key.name}..."
                    ${pkgs.gnupg}/bin/gpg --import "${key.publicKey}"
                  fi
                  if [ -f "${key.privateKey}" ]; then
                    echo "--> [GPG] Importando llave privada para: ${key.name}..."
                    ${pkgs.gnupg}/bin/gpg --import "${key.privateKey}"
                  fi

                '') cfg.keys
              );
            };
          }
        )
      ];
    };
}
