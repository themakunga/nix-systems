{
  flake.applicationModules.tailscale = {
    config,
    lib,
    pkgs,
    options,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkMerge mkForce optionalAttrs;
    cfg = config.my.tailscale;

    isLinux = options ? system.nixos;
    isDarwin = options ? system.darwin;
  in {
    options.my.tailscale = {
      enable = mkEnableOption "Universal Tailscale client";
      gui = {
        enable = mkEnableOption "Graphical interface (Trayscale on Linux, Homebrew Cask on macOS)";
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

      (optionalAttrs isLinux {
        networking.firewall = {
          trustedInterfaces = ["tailscale0"];
          allowedUDPPorts = [config.services.tailscale.port];
          checkReversePath = "loose";
        };

        environment.systemPackages = mkIf cfg.gui.enable [
          pkgs.trayscale
        ];
      })

      (optionalAttrs isDarwin {
        services.tailscale.enable = mkIf cfg.gui.enable (mkForce false);

        homebrew = mkIf cfg.gui.enable {
          enable = true;
          casks = ["tailscale"];
        };
      })
    ]);
  };
}
