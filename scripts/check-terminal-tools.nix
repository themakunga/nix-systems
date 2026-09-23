# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# nix eval --impure --json --file scripts/check-terminal-tools.nix
let
  flake = builtins.getFlake (toString ./..);
  lib = flake.inputs.nixpkgs.lib;
  check = name: host: let
    cfg = host.config;
    bootstrap = builtins.elem name ["linux-bootstrap" "aperture-bootstrap"];
    packages = map lib.getName cfg.environment.systemPackages;
    dotfiles = map (p: p.name) (cfg.my.dotfiles.packages or []);
  in
    if bootstrap
    then
      assert !(cfg.my.apps.bat.enable or false);
      assert !(cfg.my.apps.yazi.enable or false);
      assert !(cfg.my.apps.zoxide.enable or false); true
    else
      assert cfg.my.apps.bat.enable;
      assert cfg.my.apps.yazi.enable && cfg.my.apps.zoxide.enable;
      assert cfg.my.dotfiles.enable;
      assert lib.hasInfix "/bat/init.sh" cfg.environment.interactiveShellInit;
      assert (cfg.services.yabai.enable or false) == (name == "kanagawa");
      assert (cfg.services.skhd.enable or false) == (name == "kanagawa");
      assert builtins.all (p: builtins.elem p packages) ["bat" "yazi" "zoxide" "fzf"];
      assert builtins.all (p: builtins.elem p dotfiles) ["bat" "yazi" "zoxide"];
      assert lib.hasInfix "/zoxide/init.sh" cfg.environment.interactiveShellInit; true;
in
  builtins.mapAttrs check (flake.darwinConfigurations // flake.nixosConfigurations)
