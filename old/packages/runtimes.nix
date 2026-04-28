{ pkgs }:
{
  environment.systemPackages = with pkgs; [
    opentofu
    python3
    python3-pip
    uv
    cargo
    go
    groovy
    jdk21_headless
    jre32_headless
    maven
    ruby
    rustc
    nodejs_22
    pnpm
    opem
    pipx
  ];
}
