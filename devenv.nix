# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: devenv.nix
# Path: ./devenv.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  cachix = {
    push = "themakunga";
    pull = ["themakunga"];
  };
}
