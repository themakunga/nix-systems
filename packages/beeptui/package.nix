# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# beeptui — TUI for Beeper (pre-built binary, darwin-arm64 only)
# Para actualizar: cambiar version + hash del binario correspondiente.
# sha256sums: https://github.com/mitchmalone/beeptui/releases/download/v<ver>/sha256sums.txt
{
  lib,
  stdenv,
  fetchurl,
}: let
  version = "0.4.1";

  src = fetchurl {
    url = "https://github.com/mitchmalone/beeptui/releases/download/v${version}/beeptui-darwin-arm64";
    hash = "sha256-gftRNcifd5fqcAwgh/4YL2R4dYQZKgsqZzSKqxb9kWo=";
  };
in
  stdenv.mkDerivation {
    pname = "beeptui";
    inherit version;

    dontUnpack = true;

    installPhase = ''
      install -Dm755 ${src} $out/bin/beeptui
    '';

    meta = {
      description = "TUI for Beeper — terminal chat client";
      homepage = "https://github.com/mitchmalone/beeptui";
      license = lib.licenses.unfree;
      platforms = ["aarch64-darwin"];
      mainProgram = "beeptui";
    };
  }
