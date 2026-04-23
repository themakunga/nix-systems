{
  pkgs,
}:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    htop
    ctop
    btop
    fzf
    bash
  ];

  font = {
    packages = with pkgs; [
      nerd-fonts.hack
      nerd-fonts.fira-code
      nerd-fonts.noto

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
  };

}
