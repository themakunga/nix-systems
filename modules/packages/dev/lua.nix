{
  flake.commonModules.dev.lua =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        lua51Packages.lua
        luajit
        luajitPackages.luarocks
        lua-language-server
        stylua
        luacheck
      ];
    };
}
