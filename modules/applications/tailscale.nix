{
  flake.commonModules.tailscale = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkMerge mkForce;
    inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
    cfg = config.my.tailscale;
  in {
    options.my.tailscale = {
      enable = mkEnableOption "Cliente Tailscale universal";
      gui = {
        enable = mkEnableOption "Interfaz gráfica (Trayscale en Linux, Homebrew Cask en macOS)";
      };
    };

    config = mkIf cfg.enable (mkMerge [
      {
        sops.secrets."tailscale/auth_token" = {};
      }

      {
        services.tailscale = {
          enable = true;
          authKeyFile = config.sops.secrets."tailscale/auth_token".path;
        };

        environment.systemPackages = [pkgs.tailscale];
      }

      (mkIf isLinux {
        networking.firewall = {
          trustedInterfaces = ["tailscale0"];
          allowedUDPPorts = [config.services.tailscale.port];

          checkReversePath = "loose";
        };

        environment.systemPackages = mkIf cfg.gui.enable [
          pkgs.trayscale
        ];
      })

      (mkIf isDarwin (mkIf cfg.gui.enable {
        services.tailscale.enable = mkForce false;

        homebrew = {
          enable = true;
          casks = ["tailscale"];
        };
      }))
    ]);
  };
}
