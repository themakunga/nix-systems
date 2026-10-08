# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: settings.nix
# Path: ./modules/modules/common/settings.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  globals,
  self,
  ...
}: let
  inherit (self) overlays;
in {
  flake.commonModules.settings = {
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
    inherit (lib) mkIf optionals mkMerge;
    inherit (globals.stateVersion) darwin nixos;
  in {
    system.stateVersion = mkMerge [
      (mkIf isLinux nixos)
      (mkIf isDarwin darwin)
    ];
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users =
          [
            "root"
            "nicolas"
          ]
          ++ optionals isLinux ["@wheel"]
          ++ optionals isDarwin ["@admin"];
      };
    };
    nixpkgs = {
      config = {
        allowUnfree = true;
        problems.handlers.pynput.broken = "ignore";
      };
      overlays = [
        overlays.unstable
        # poetry 2.4.1 tiene un test flaky (test_call_does_not_block_on_full_pipe)
        # que falla en build local cuando el cache binario no lo tiene.
        (_: prev: {
          poetry = prev.poetry.overridePythonAttrs (_: {doCheck = false;});
        })
      ];
    };
  };
}
