# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Common configuration for all of Nicolas's macOS workstations.
# Included automatically via darwin.base bundle → profileModules.
_: {
  flake.profileModules.darwin-mac = {pkgs, ...}: {
    my = {
      dotfiles.enable = true;
      primaryUser = {
        enable = true;
        username = "nicolas";
      };
      keyboard.enable = true;

      devices = {
        audio.enable = true;
        logitech.enable = true;
        sony.enable = true;
        hyperx.enable = true;
      };

      weather = {
        enable = true;
        location = "Quebrada de Macul, Chile";
        units = "c";
        forecast = ["d" "w"];
      };

      packages = with pkgs; [stow pre-commit];

      # zen + ghostty already come from the personal profile
      casks = ["iterm2" "wezterm" "ferdium" "reminders-menubar"];

      masApps = {
        "Amphetamine" = 937984704;
        "Magnet" = 441258766;
        "Xcode" = 497799835;
      };

      # github-cli already enabled by the personal profile
      apps = {
        tailscale-core.enable = true;
        tailscale-gui.enable = true;
        neovim.enable = true;
        terminal-zsh.enable = true;
        gcloud.enable = true;
        ghostty.enable = true;
        halloy.enable = true;
        irssi.enable = true;
        nchat.enable = true;
      };

      tools.devenv.enable = true;

      services.janitor = {
        enable = true;
        cleanCaches = true;
        emptyTrash = true;
        cleanXcode = true;
        cleanBrew = true;
        cleanNpm = true;
        cleanTerraform = true;
        cleanGolang = true;
        cleanJava = true;
        cleanPython = true;
        cleanNix = true;
      };

      development = {
        containers = {
          enable = true;
          runtime = "colima";
          kubernetes = true;
          argocd = false;
        };
        aws = {
          enable = true;
          enableSSM = true;
          enableLocalStack = true;
        };
        gcp = {
          enable = true;
          enableGkePlugin = true;
        };
        iac = {
          enable = true;
          enableOpenTofu = true;
          enableTerraform = false;
          enablePulumi = true;
        };
        argocd = {
          enable = true;
          enableAutopilot = true;
        };
        nodejs = {
          enable = true;
          package = pkgs.nodejs_24;
          packageManager = "pnpm";
          enableBun = true;
          enableGlobals = true;
        };
        python = {
          enable = true;
          package = pkgs.python3;
          enablePoetry = true;
        };
        golang.enable = true;
        rust.enable = true;
        java = {
          enable = true;
          jdk = pkgs.jdk21;
          enableMaven = true;
          enableGradle = true;
        };
        ruby = {
          enable = true;
          package = pkgs.ruby;
        };
        groovy = {
          enable = true;
          enableGradle = true;
        };
        swift = {
          enable = true;
          enableTuist = true;
          enableFastlane = true;
        };
      };
    };
  };
}
