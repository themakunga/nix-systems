{inputs, ...}: {
  flake.applicationModules.tailscale = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) mkIf mkMerge;
    inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  in
    mkMerge [
      {
        sops.secrets."tailscale/auth_key" = {
          sopsFile = "${inputs.secrets}/common.yaml";
        };

        services.tailscale.enable = true;
      }
      (mkIf isLinux {
        service.tailscale.authKeyFile = config.sops.secrets."tailscale/auth_key".path;

        networking.firewall = {
          trustedInterfaces = ["tailscale0"];
          allowedUDPPorts = [config.services.tailscale.port];
        };
      })
      (mkIf isDarwin {
        system.activationScripts.postActivation.text = ''
          echo "[Tailscale] Daemon activated.Si es tu primera vez en este Mac, ejecuta el siguiente comando para autenticarte:"
          echo "sudo tailscale up --authkey \$(cat ${config.sops.secrets."tailscale/auth_key".path})"
        '';
      })
    ];
}
