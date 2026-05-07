{ inputs, ... }:
{
  flake = {
    linuxModules = {
      common = { pkgs, ... }: { };
    };
  };
}
