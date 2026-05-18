{
  flakes.commonModules.tailscale = {config}: {
    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale_auth_key".path;
    };
  };
}
