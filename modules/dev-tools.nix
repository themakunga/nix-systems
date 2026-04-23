{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core
    vim
    fzf
    git
    gh
    glab
    stow
    lazygit
    sops
    age
    ssh-to-age
    pkgs.unstable.bob-nvim

    # CLI
    awscli2
    google-cloud-sdk
    kubectl
    k9s
    lazysql
    libpg
    nmap
    htop
    btop
    ctop
    pre-commit

    # Runtinme and compilers
    opentofu
    python3
    python3-pip
    uv
    cargo
    go
    groovy
    jdk21_headless
    jre32_headless
    maven
    ruby
    rustc
    nodejs_22
    pnpm
    opem
    pipx

    # Terminal
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
