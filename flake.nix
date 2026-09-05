# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: flake.nix
# Path: ./flake.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  description = "Flake build rpi installers and multi host systems";

  nixConfig = {
    extra-substitutions = ["https://themakunga.cachix.org"];
    extra-trusted-public-keys = [
      "themakunga.cachix.org-1:6G4uSeEclXBILBnmlbDsTAapL2vE0ndx4laL02AzzR0="
    ];
    connect-timeout = 5;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/TheMakunga/.secrets.git";
      flake = false;
    };

    tofu-dns = {
      # Usando github: (HTTPS via API) en vez de git+ssh para que el CI
      # pueda fetchear usando GH_TOKEN_SECRETS sin necesitar SSH key.
      url = "github:TheMakunga/tofu-dns";
      flake = false;
    };

    globalprotect-openconnect.url = "github:yuezk/GlobalProtect-openconnect";
  };

  outputs = inputs: let
    globals = {
      stateVersion = {
        nixos = "26.05";
        darwin = 6;
      };
    };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      _module.args = {inherit globals;};

      imports = [
        (inputs.import-tree ./modules)
      ];
    };
}
