{
  flake.commonModules.tailscale = {config}: {
    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale_auth_key".path;
    };

    authKeyFile = config.sops.secrets."tailscale/auth_key".path;

    networking.firewall.allowedUDPPorts = [41641];
  };
}
