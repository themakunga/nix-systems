# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo: applicationModules.obsidian
# =========================================================
# Obsidian — instalación via Homebrew cask (solo Darwin).
#
# Config inicial (no sensible) vive en public-dotfiles/obsidian/obsidian.json.
# El script de activación la copia a ~/Library/Application Support/obsidian/
# solo si el archivo no existe aún — preserva la config gestionada por Obsidian.
#
# Los vaults están en ~/.vaults (repositorio git propio, no gestionado aquí).
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.obsidian = mkAppModule "obsidian" "Obsidian knowledge base" {
    meta = {
      pkgs,
      lib,
      ...
    }: {
      level = "system";
      # Última versión disponible via Homebrew (cask siempre apunta a latest release)
      casks = lib.optionals pkgs.stdenv.isDarwin ["obsidian"];
    };

    sysConfig = {pkgs, ...}: let
      isDarwin = pkgs.stdenv.isDarwin;
      user = "nicolas";
      userHome = "/Users/${user}";

      # Fuente: config no sensible clonada por el módulo dotfiles en ~/.public-dotfiles/
      # Resiliente: si el repo aún no fue clonado (primera activación), se omite
      # y completa en el siguiente darwin-rebuild switch.
      setupScript = ''
        DOTFILES_SRC="${userHome}/.public-dotfiles/obsidian/obsidian.json"
        OBSIDIAN_DIR="${userHome}/Library/Application Support/obsidian"
        OBSIDIAN_JSON="$OBSIDIAN_DIR/obsidian.json"

        if [ -f "$DOTFILES_SRC" ] && [ ! -f "$OBSIDIAN_JSON" ]; then
          echo "=> Inicializando config de Obsidian..."
          mkdir -p "$OBSIDIAN_DIR"
          # Sustituye HOME_PLACEHOLDER por el home real del usuario
          ${pkgs.gnused}/bin/sed "s|HOME_PLACEHOLDER|${userHome}|g" \
            "$DOTFILES_SRC" > "$OBSIDIAN_JSON"
          # El directorio se creó como root; Obsidian necesita escribir en él
          chown -R ${user} "$OBSIDIAN_DIR"
          chmod 644 "$OBSIDIAN_JSON"
        fi
      '';
    in {
      # Solo aplica en Darwin; en Linux Obsidian corre en el container Hermes
      system.activationScripts =
        if isDarwin
        then {postActivation.text = setupScript;}
        else {};
    };
  };
}
