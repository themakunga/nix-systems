{
  flake.commonModules.fonts = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      fira-code
      fira-code-symbols
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.meslo-lg
      nerd-fonts.victor-mono
      nerd-fonts.ubuntu
    ];
  };
}
