# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.grainger = _: {
    # PENDIENTE: agregar profiles/grainger/{gpg,ssh} a outer-heaven.yaml
    # cuando las llaves GPG estén disponibles para importar.
    # SSH: ~/.ssh/id_ed25519_grangier gestionado por secret-dotfiles.
    # GPG fingerprint: literal en outer-heaven-workspaces.nix.
    programs.git-identity.enable = true;
  };
}
