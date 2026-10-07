# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.terminal-tools = {pkgs, ...}: let
    # gws-tui — not in nixpkgs; patches in tokyonight-storm palette
    gws-tui = pkgs.buildGoModule rec {
      pname = "gws-tui";
      version = "0.1.0";

      src = pkgs.fetchFromGitHub {
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

      meta = with pkgs.lib; {
        description = "Terminal UI for Google Workspace";
        homepage = "https://github.com/fabhiansan/gws-tui";
        license = licenses.mit;
        platforms = platforms.unix;
      };
    };
  in {
    my = {
      agentWiki = {
        enable = true;
        autoSync.enable = true; # launchd agent: sync cada 5 min en background
      };
      claudeHooks.enable = true;
      dotfiles.enable = true;
      dotfiles.packages = [
        {
          name = "codex";
          output-name = ".codex";
        }
        {
          name = "claude";
          output-name = ".claude";
        }
        {
          name = "scripts";
          output-name = "scripts";
        }
      ];
      packages = [pkgs.unstable.tuxedo gws-tui];
      apps = {
        bat.enable = true;
        glow.enable = true;
        token-counter.enable = true;
        yazi.enable = true;
        zoxide.enable = true;
      };
    };
  };
}
