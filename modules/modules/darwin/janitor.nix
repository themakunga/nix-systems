# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: janitor.nix
# Path: ./modules/modules/darwin/janitor.nix
# Description: Suite de limpieza y gestión de espacio para macOS (Estilo CCleaner CLI)
# =====================
{
  flake.darwinModules.janitor = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;

    # Apuntamos al nuevo namespace: my.services.janitor
    cfg = config.my.services.janitor;

    # Helper para convertir booleanos de Nix a "1" o "0" para Bash
    boolToInt = b:
      if b
      then "1"
      else "0";

    # Script principal de limpieza
    janitorScript = pkgs.writeShellScriptBin "janitor" ''
      #!/usr/bin/env bash
      echo "🧹 Iniciando protocolo de limpieza (Janitor)..."

      SPACE_BEFORE=$(df -h / | awk 'NR==2 {print $4}')
      echo "Espacio libre inicial: $SPACE_BEFORE"
      echo "---------------------------------------------------"

      # 1. Cachés de Sistema y Usuario
      if [ "${boolToInt cfg.cleanCaches}" = "1" ]; then
        echo "=> Limpiando cachés del usuario (~/Library/Caches)..."
        rm -rf ~/Library/Caches/* 2>/dev/null || true
      fi

      # 2. Papelera
      if [ "${boolToInt cfg.emptyTrash}" = "1" ]; then
        echo "=> Vaciando Papelera..."
        rm -rf ~/.Trash/* 2>/dev/null || true
      fi

      # 3. Xcode DerivedData y Caches
      if [ "${boolToInt cfg.cleanXcode}" = "1" ]; then
        echo "=> Limpiando basura de Xcode..."
        rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
        rm -rf ~/Library/Developer/Xcode/Archives/* 2>/dev/null || true
        rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/* 2>/dev/null || true
      fi

      # 4. Homebrew
      if [ "${boolToInt cfg.cleanBrew}" = "1" ] && command -v brew >/dev/null 2>&1; then
        echo "=> Limpiando Caches antiguos de Homebrew..."
        brew cleanup -s --prune=all
      fi

      # 5. NPM / Yarn Caches (Desarrollo Frontend)
      if [ "${boolToInt cfg.cleanNpm}" = "1" ]; then
        echo "=> Limpiando cachés de NodeJS (NPM/Yarn)..."
        rm -rf ~/.npm/_cacache 2>/dev/null || true
        rm -rf ~/.yarn/cache 2>/dev/null || true
      fi

      # 6. Terraform / OpenTofu
      if [ "${boolToInt cfg.cleanTerraform}" = "1" ]; then
        echo "=> Limpiando plugins globales de Terraform y OpenTofu..."
        rm -rf ~/.terraform.d/plugin-cache/* 2>/dev/null || true
        rm -rf ~/.tofu/plugin-cache/* 2>/dev/null || true
      fi

      # 7. Golang (Build y Mod cache)
      if [ "${boolToInt cfg.cleanGolang}" = "1" ]; then
        echo "=> Limpiando cachés de compilación y módulos de Golang..."
        if command -v go >/dev/null 2>&1; then
          go clean -cache -modcache -testcache 2>/dev/null || true
        else
          rm -rf ~/Library/Caches/go-build/* 2>/dev/null || true
          rm -rf ~/go/pkg/mod/* 2>/dev/null || true
        fi
      fi

      # 8. Java (Maven / Gradle)
      if [ "${boolToInt cfg.cleanJava}" = "1" ]; then
        echo "=> Limpiando cachés de Maven y Gradle..."
        rm -rf ~/.m2/repository/* 2>/dev/null || true
        rm -rf ~/.gradle/caches/* 2>/dev/null || true
        rm -rf ~/.gradle/daemon/* 2>/dev/null || true
      fi

      # 9. Python (Pip / Poetry)
      if [ "${boolToInt cfg.cleanPython}" = "1" ]; then
        echo "=> Limpiando cachés de PIP y Poetry..."
        rm -rf ~/.cache/pip/* 2>/dev/null || true
        rm -rf ~/.cache/pypoetry/cache/* 2>/dev/null || true
        rm -rf ~/Library/Caches/pip/* 2>/dev/null || true
        rm -rf ~/Library/Caches/pypoetry/* 2>/dev/null || true
      fi

      # 10. Nix Garbage Collection
      if [ "${boolToInt cfg.cleanNix}" = "1" ]; then
        echo "=> Ejecutando Nix Garbage Collector..."
        sudo nix-collect-garbage -d
        nix-collect-garbage -d
        nix store optimise
      fi

      echo "---------------------------------------------------"
      SPACE_AFTER=$(df -h / | awk 'NR==2 {print $4}')
      echo "✅ ¡Limpieza completada!"
      echo "Espacio libre final: $SPACE_AFTER"
      echo ""
      echo "💡 Tip: Usa el comando 'gdu' para ver un mapa interactivo de tu disco."
    '';
  in {
    # Declaramos las opciones bajo my.services.janitor
    options.my.services.janitor = {
      enable = mkEnableOption "Habilitar herramienta de limpieza y optimización para macOS";

      cleanCaches = mkOption {
        type = types.bool;
        default = true;
        description = "Limpiar ~/Library/Caches";
      };
      emptyTrash = mkOption {
        type = types.bool;
        default = true;
        description = "Vaciar la papelera automáticamente";
      };
      cleanXcode = mkOption {
        type = types.bool;
        default = false;
        description = "Limpiar cachés y DerivedData de Xcode";
      };
      cleanBrew = mkOption {
        type = types.bool;
        default = true;
        description = "Limpiar Homebrew";
      };
      cleanNpm = mkOption {
        type = types.bool;
        default = true;
        description = "Limpiar cachés de NPM/Yarn";
      };

      cleanTerraform = mkOption {
        type = types.bool;
        default = true;
        description = "Limpiar cachés de plugins de Terraform y OpenTofu";
      };
      cleanGolang = mkOption {
        type = types.bool;
        default = true;
        description = "Limpiar modcache y build cache de Go";
      };
      cleanJava = mkOption {
        type = types.bool;
        default = true;
        description = "Limpiar repositorios de Maven (.m2) y cachés de Gradle";
      };
      cleanPython = mkOption {
        type = types.bool;
        default = true;
        description = "Limpiar cachés de Pip y Poetry";
      };

      cleanNix = mkOption {
        type = types.bool;
        default = false;
        description = "Ejecutar recolección de basura de Nix al limpiar";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        janitorScript
        gdu
        duf
      ];
    };
  };
}
