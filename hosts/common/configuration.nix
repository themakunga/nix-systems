{ pkgs, ... }:
{
  nix.settings.experimental-featutures = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    btop
    ctop
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
