{
  flake.commonModules.dev.ruby = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ruby
      bundler
      ruby-lsp
      rubocop
    ];
  };
}
