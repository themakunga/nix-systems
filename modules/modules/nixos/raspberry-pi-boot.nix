{
  flake.nixosModules.raspberry-pi-config = {
    pkgs,
    nixpkgs,
    secrets,
    ...
  }: {
    system.stateVersion = "25.11";

    nix.settings.experimental-features = [
      "nix-command"
      "nix-flakes"
    ];

    imports = [
      "${nixpkgs}/nixos/modules/intallers/sd-card/sd-image-aarch64.nix"
    ];

    nixpkgs = {
      buildPlatform = "x86_64-linux";
      hostPlatform = "aarch64-linux";
    };

    boot.loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = false;
      efi.canTouchEfiVariables = false;
    };

    hardware.deviceTree.enable = true;

    fileSystems."/" = {
      device = "/";
      fsType = "ext4";
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    users.users.root.openssh.authorizedKeys.keys = [
      (builtins.readFile "${secrets}/public-keys/outer-heaven.pub")
      (builtins.readFile "${secrets}/public-keys/kanagawa.pub")
      (builtins.readFile "${secrets}/public-keys/motherbase.pub")
      (builtins.readFile "${secrets}/public-keys/wheatley.pub")
      (builtins.readFile "${secrets}/public-keys/glaDOS.pub")
      (builtins.readFile "${secrets}/public-keys/mediaserver.pub")
    ];

    environment.systemPackages = with pkgs; [
      git
      curl
      disko
    ];
  };
}
