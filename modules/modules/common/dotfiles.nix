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
_: {
  flake.commonModules.dotfiles = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.dotfiles;
    user = config.system.primaryUser or "nicolas";
    userHome =
      if pkgs.stdenv.isDarwin
      then "/Users/${user}"
      else "/home/${user}";
    dotfilesDir = "${userHome}/Projects/personal/public-dotfiles";
  in {
    options.my.dotfiles = {
      enable = mkEnableOption "Enable GNU Stow automatic activation for dotfiles";
      packages = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of package names to stow from public-dotfiles.";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [pkgs.stow];

      system.activationScripts.stowDotfiles = {
        text = ''
          echo "Checking for local dotfiles in ${dotfilesDir}..."
          if [ -d "${dotfilesDir}" ]; then
            echo "Stowing dotfiles for user ${user}..."
            ${builtins.concatStringsSep "\n" (builtins.map (pkg: ''
              if [ -d "${dotfilesDir}/${pkg}" ]; then
                sudo -u ${user} ${pkgs.stow}/bin/stow -t ${userHome} -d ${dotfilesDir} --restow ${pkg}
              fi
            '')
            cfg.packages)}
            echo "Dotfiles stowed successfully."
          else
            echo "Local dotfiles directory not found at ${dotfilesDir}. Skipping stow."
          fi
        '';
      };
    };
  };
}
