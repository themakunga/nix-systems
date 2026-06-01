{
  flake.commonModules.tailscale = {config, ...}: {
    sops.secrets."tailscale/auth_key" = {};

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale/auth_key".path;
    };

    networking.firewall.allowedUDPPorts = [41641];
  };
}
