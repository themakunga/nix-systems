# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.rust
# =========================================================
{
  flake.developmentModules.rust = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.development.rust;
  in {
    options.my.development.rust = {
      enable = mkEnableOption "Rust development toolkit (Cargo, rustc, rust-analyzer)";
      useDotfiles = mkOption {
        type = types.bool;
        default = true;
      };
      useSecrets = mkOption {
        type = types.bool;
        default = false;
      };
    };

    config = mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs; [
          # Toolchain de Rust (Sustituye el uso manual de rustup)
          cargo
          rustc
          rustfmt
          clippy

          # LSPs (Language Server)
          rust-analyzer

          # Herramientas de productividad
          cargo-watch
          cargo-audit
        ];
        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/rust/env".path}" ]; then
            source "${config.sops.secrets."development/rust/env".path}"
          fi
        '';
      };

      # Configuración Pública (Dotfiles vía Stow)
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "rust";
          isConfig = false; # Ideal para ~/.cargo/config.toml público
        }
      ];

      # Configuración Sensible (SOPS)
      sops.secrets."development/rust/env" = mkIf cfg.useSecrets {};
    };
  };
}
