# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: deviceModules.sony
# =========================================================
{
  flake.deviceModules.sony = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkAfter mkEnableOption mkIf mkMerge;
    cfg = config.my.devices.sony;
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

    # SonyBridge macOS app — installed directly from GitHub releases.
    # ponytail: fetchurl over fetchzip to reuse homebrew's known sha256.
    sonyBridge = pkgs.stdenvNoCC.mkDerivation {
      pname = "SonyBridge";
      version = "0.3.3";
      src = pkgs.fetchurl {
        url = "https://github.com/AmitRajput-Dev/SonyBridge/releases/download/v0.3.3/SonyBridge-macOS.zip";
        hash = "sha256-NOaWZbXvLIe6qst2qpXBIb9QVgP51gSubeNyQ/NrEWM=";
      };
      nativeBuildInputs = [pkgs.unzip];
      unpackPhase = "unzip $src";
      installPhase = ''
        mkdir -p $out/Applications
        cp -r SonyBridge.app $out/Applications/
      '';
      meta = {
        description = "Control Sony headphones (noise cancelling, ambient sound, EQ, battery) from macOS";
        homepage = "https://github.com/AmitRajput-Dev/SonyBridge";
        platforms = lib.platforms.darwin;
      };
    };
  in {
    options.my.devices.sony = {
      enable = mkEnableOption "Habilitar utilidades y ecualización para audífonos Sony";
    };

    config = mkIf cfg.enable (mkMerge [
      (mkIf isDarwin {
        homebrew.casks = ["eqmac"];
        environment.systemPackages = [sonyBridge pkgs.switchaudio-osx];
        # Clear quarantine so ad-hoc signed app launches without Gatekeeper block.
        system.activationScripts.postActivation.text = mkAfter ''
          find /Applications /Users -maxdepth 5 -name "SonyBridge.app" \
            -exec /usr/bin/xattr -dr com.apple.quarantine {} \; 2>/dev/null || true
        '';
      })

      (mkIf (!isDarwin) {
        environment.systemPackages = with pkgs; [pavucontrol];
      })
    ]);
  };
}
