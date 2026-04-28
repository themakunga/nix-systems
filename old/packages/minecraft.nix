{pkgs}: {
  environment.systemPackages = with pkgs; [
    prismalauncher
  ];
}
