# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  lib,
  swiftPackages,
}: let
  inherit (swiftPackages) stdenv swift;
in
  stdenv.mkDerivation {
    pname = "point-reader";
    version = "1.0.0";
    src = ./.;
    nativeBuildInputs = [swift];
    buildPhase = ''
      runHook preBuild
      swiftc -O Reader.swift main.swift -o point-reader
      swiftc Reader.swift Tests.swift -o extraction-tests
      runHook postBuild
    '';
    doCheck = true;
    checkPhase = ''
      runHook preCheck
      ./extraction-tests
      runHook postCheck
    '';
    installPhase = ''
      runHook preInstall
      app="$out/Applications/Point Reader.app/Contents"
      mkdir -p "$app/MacOS"
      cp point-reader "$app/MacOS/point-reader"
      cp Info.plist "$app/Info.plist"
      runHook postInstall
    '';
    meta = {
      description = "Read selected text or the accessible block under the pointer";
      platforms = lib.platforms.darwin;
    };
  }
