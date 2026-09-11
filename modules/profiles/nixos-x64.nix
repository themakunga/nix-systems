# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Common configuration for all of Nicolas's x86_64 NixOS machines.
# Included automatically via nixos.base bundle → profileModules.
_: {
  flake.profileModules.nixos-x64 = _: {
    my = {
      dotfiles.enable = true;
      keyboard.enable = true;
      apps.tailscale-core.enable = true;
    };
  };
}
