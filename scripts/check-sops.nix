# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Run: nix eval --impure --json --file scripts/check-sops.nix
let
  flake = builtins.getFlake (toString ../.);
  lib = flake.inputs.nixpkgs.lib;
  checkDarwin = host: let
    cfg = host.config;
    keys = cfg.sops.age.sshKeyPaths;
  in
    assert keys == lib.unique keys;
    assert builtins.all (secret: !secret.neededForUsers) (builtins.attrValues cfg.sops.secrets);
    assert !(cfg.launchd.daemons ? sops-install-secrets-for-users);
    assert !(lib.hasInfix "Setting up secrets for users" cfg.system.activationScripts.postActivation.text);
    assert lib.hasInfix "Setting up secrets..." cfg.system.activationScripts.postActivation.text; true;
  checkLinux = name: let
    profile = flake.userModules.${name} {
      config = {};
      pkgs.stdenv.isLinux = true;
    };
  in
    assert profile.sops.secrets."passwords/nicolas/hashed".neededForUsers; true;
in {
  darwin = builtins.mapAttrs (_: checkDarwin) flake.darwinConfigurations;
  linuxPasswordPhase = map checkLinux ["personal" "work"];
}
