{
  flake.commonModules.core.cli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        age
        bash
        btop
        dott-tui
        fd
        fzf
        glab
        neofetch
        nmap
        oh-my-posh
        qmk
        ripgrep
        sops
        ssh-to-age
        stow
        tmux
      ];
    };
}
