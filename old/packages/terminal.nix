{ pkgs }:
{
  environment.systemPackages = with pkgs; [
    tmux
    oh-my-posh
    bash
    zsh
    ripgrep
    fd
    neofetch
    irssi
    pkgs.unstable.nchat

    nil
    nixfmt-rfc-style

  ];
}
