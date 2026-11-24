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
      assert name != "aperture-science" || builtins.elem "tmux" packages;
      assert lib.hasInfix "/bat/init.sh" cfg.environment.interactiveShellInit;
      assert builtins.all (p: builtins.elem p packages) ["bat" "yazi" "zoxide" "fzf"];
      assert builtins.all (p: builtins.elem p dotfiles) ["bat" "yazi" "zoxide"];
      assert lib.hasInfix "/zoxide/init.sh" cfg.environment.interactiveShellInit; true;
  aperture = flake.nixosConfigurations.aperture-science.config;
  aperturePackages = map lib.getName aperture.environment.systemPackages;
  apertureDotfiles = map (p: p.name) aperture.my.dotfiles.packages;
in
  assert aperture.my.apps.terminal-zsh.enable;
  assert aperture.programs.zsh.enable;
  assert lib.getName aperture.users.users.wheatley.shell == "zsh";
  assert lib.getName aperture.users.users.nicolas.shell == "bash-interactive";
  assert builtins.all (p: builtins.elem p aperturePackages) ["zsh" "tmux" "fzf" "oh-my-posh" "fastfetch" "lazygit"];
  assert builtins.all (p: builtins.elem p apertureDotfiles) ["zsh" "tmux" "wezterm" "ohmyposh" "fastfetch"];
  assert builtins.elem flake.nixosConfigurations.aperture-science.pkgs.nerd-fonts.hack aperture.fonts.packages;
  assert lib.hasInfix "fzf-tab.plugin.zsh" aperture.environment.etc."zsh/plugins.zsh".text;
  assert lib.hasInfix "zsh-autosuggestions.zsh" aperture.environment.etc."zsh/plugins.zsh".text;
  assert lib.hasInfix "zsh-syntax-highlighting.zsh" aperture.environment.etc."zsh/plugins.zsh".text;
  assert lib.hasInfix "TMUX_PLUGIN_MANAGER_PATH /etc/tmux/plugins/" aperture.environment.etc."tmux/plugins.conf".text;
  assert builtins.all (plugin: lib.hasInfix plugin aperture.environment.etc."tmux/plugins.conf".text) ["resurrect.tmux" "continuum.tmux" "vim-tmux-navigator.tmux" "sessionx.tmux" "plugin.sh.tmux"];
  assert lib.hasInfix "PKG_NAME=\"zsh\"" aperture.system.activationScripts.stowDotfiles.text;
    builtins.mapAttrs check (flake.darwinConfigurations // flake.nixosConfigurations)
