{
  flake.commonModules.dev-nodejs = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      nodejs_24
      pnpm
      typescript
      typescript-language-server
      eslint_d
      prettierd
    ];
  };
}
