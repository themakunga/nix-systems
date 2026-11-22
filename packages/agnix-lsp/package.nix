# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Agent configuration validation for the platforms used by this flake.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  targets = {
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-rl7W7jUe6xECAuNwLhUDXvU1FGyJF0MC0+l6m3sFYeI=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-gnu";
      hash = "sha256-IZu206Fq7Xowh2ksFBXFbJf6LP/yZu5GmkzjEfxy2V8=";
    };
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-2PVf7wd47PBw9KEAW2aHBgxXdXd0saz+g2yMdIhJlxY=";
    };
  };
  inherit (targets.${stdenv.hostPlatform.system}) target hash;
in
  stdenv.mkDerivation rec {
    pname = "agnix-lsp";
    version = "0.61.0";
    src = fetchurl {
      url = "https://github.com/agent-sh/agnix/releases/download/v${version}/agnix-lsp-${target}.tar.gz";
      inherit hash;
    };
    sourceRoot = ".";
    nativeBuildInputs = lib.optionals (stdenv.hostPlatform.system == "aarch64-linux") [autoPatchelfHook];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [stdenv.cc.cc.lib];
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 agnix-lsp "$out/bin/agnix-lsp"
      runHook postInstall
    '';
    meta = {
      description = "Language server for AI agent configuration files";
      homepage = "https://github.com/agent-sh/agnix";
      license = with lib.licenses; [mit asl20];
      platforms = builtins.attrNames targets;
      mainProgram = "agnix-lsp";
    };
  }
