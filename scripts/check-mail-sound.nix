# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# nix eval --impure --json --file scripts/check-mail-sound.nix
let
  flake = builtins.getFlake (toString ./..);
  inherit (flake.inputs.nixpkgs) lib;
in
  builtins.mapAttrs (_: host: let
    script = host.config.system.activationScripts.postActivation.text;
    home = host.config.users.users.${host.config.system.primaryUser}.home;
  in
    assert lib.hasInfix (lib.escapeShellArg "${home}/Library/Sounds/AOL You've Got Mail.wav") script;
    assert lib.hasInfix "defaults write com.apple.mail MailSound" script;
    assert lib.hasInfix "aol-youve-got-mail.wav" script;
    assert lib.hasInfix "Mail > Settings > General" script; true)
  flake.darwinConfigurations
