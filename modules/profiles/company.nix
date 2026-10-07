# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.company = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
  in {
    # PENDIENTE: agregar profiles/42devs/{gpg,ssh} a outer-heaven.yaml
    # cuando las llaves GPG de 42devs estén disponibles para importar.
    # SSH: ~/.ssh/id_ed25519_42devs gestionado por secret-dotfiles.
    # GPG fingerprint: literal en outer-heaven-workspaces.nix.

    my.casks = mkIf isDarwin [
      "firefox"
      "firefox@developer-edition"
    ];

    programs.git-identity.enable = true;
  };
}
