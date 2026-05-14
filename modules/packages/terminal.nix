{
  flake = {
    commonModules.terminal = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        git
        vim
        htop
        btop
        ctop
        ripgrep
        fd
        curl
        wget
      ];
    };
  };
}
