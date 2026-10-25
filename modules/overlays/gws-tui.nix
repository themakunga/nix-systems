# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# gws-tui — Terminal UI for Google Workspace (not in nixpkgs)
# Patches in a "tokyonight-storm" palette (upstream only ships Night: #1a1b26).
{
  flake.overlays.gws-tui = final: _prev: {
    gws-tui = final.buildGoModule rec {
      pname = "gws-tui";
      version = "0.1.0";

      src = final.fetchFromGitHub {
        owner = "fabhiansan";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-k/tdtdv7KtcB++jeInX+wkMo3bJ6uxsOmP7k86Ypos8=";
      };

      vendorHash = "sha256-MYkYfyXQ+YDKwZGVvAkZFDBRSyh9o4STrSCGBZMGbHo=";

      # Inject Tokyo Night Storm palette — bg #24283b vs Night #1a1b26
      postPatch = ''
               substituteInPlace internal/tui/theme/theme.go \
                 --replace-fail \
                   '"tokyonight": {' \
                   '"tokyonight-storm": {
        	Accent:       "#bb9af7",
        	Live:         "#9ece6a",
        	Warn:         "#e0af68",
        	Error:        "#f7768e",
        	Info:         "#7aa2f7",
        	Subtle:       "#565f89",
        	Bg:           "#24283b",
        	Surface:      "#1f2335",
        	SurfaceAlt:   "#292e42",
        	Fg:           "#c0caf5",
        	FgMuted:      "#a9b1d6",
        	Border:       "#3b4261",
        	BorderActive: "#bb9af7",
        	Selected:     "#2d3f76",
        	StatusFg:     "#24283b",
        },
        "tokyonight": {'
      '';

      meta = with final.lib; {
        description = "Terminal UI for Google Workspace";
        homepage = "https://github.com/fabhiansan/gws-tui";
        license = licenses.mit;
        platforms = platforms.unix;
      };
    };
  };
}
