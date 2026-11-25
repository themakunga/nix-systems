# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  lib,
  fetchFromGitHub,
  python3Packages,
  gitMinimal,
  babashka,
  clojure,
  python3,
  tmux,
  writeShellApplication,
}: let
  source = repo: rev: hash:
    fetchFromGitHub {
      owner = "unclebob";
      inherit repo rev hash;
    };
  tool = pname: src: dependencies:
    python3Packages.buildPythonApplication {
      inherit pname src dependencies;
      version = "0.1.0";
      pyproject = true;
      build-system = [python3Packages.setuptools];
      nativeCheckInputs = [python3Packages.pytestCheckHook gitMinimal babashka];
      pythonImportsCheck = [pname];
      preCheck = ''
        export HOME="$TMPDIR"
      '';
      meta = {
        homepage = "https://github.com/unclebob/${pname}";
        license = lib.licenses.bsd0;
        mainProgram = pname;
      };
    };
  parsers = with python3Packages; [tree-sitter tree-sitter-language-pack];
  crapper = tool "crapper" (source "crapper"
    "c757ec79a6c15dc815238bbd9c2f4601eb54d3cc"
    "sha256-iWEXCRF60ax2vyWfs7ZQ0B8VwdGlgCCZwYFn4rN0URI=")
  parsers;
  dryer = tool "dryer" (source "dryer"
    "66ff6d21a42c04afcad89c78a80066176d1294b0"
    "sha256-EwoP89k6YllcN6dmn/rxbeqDoAMOQsKfjpzfykD6PKA=")
  parsers;
  mutator = tool "mutator" (source "mutator"
    "0136cf555797f1c9552388c40207eb2f13af9535"
    "sha256-SRudslYZ9ERCzSyQIZg/Tgi9Yp5lrc7WljzTz8Hi6iM=") (parsers ++ [crapper]);
  viewer =
    source "uml-viewer"
    "ad6c36d964ef4dab07623ab98122d72010ecb5a6"
    "sha256-TIKwAuQpM6T77I/Ua+Zgg+HkoPC/FN1tJAVn8RXJZMw=";
in {
  inherit crapper dryer mutator;
  skill =
    source "ub-mode"
    "3da62bf3fcfd2034de41f30d920d2739e566171f"
    "sha256-Az6UoipXKejGXnRHyhYk0NqVbYMqcjI5DEvSbyT0PFo=";
  uml-viewer = writeShellApplication {
    name = "uml-viewer";
    runtimeInputs = [clojure python3 tmux crapper dryer mutator];
    # shortcut: pinned Maven dependencies populate the user cache on first run; vendor for offline use.
    text = ''
      exec clojure -Sdeps '{:deps {io.github.unclebob/uml-viewer {:local/root "${viewer}"} quil/quil {:mvn/version "4.3.1563"}}}' \
        -M -m uml-viewer.main.uml-viewer "$@"
    '';
  };
}
