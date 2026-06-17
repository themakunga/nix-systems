{
  # self,
  inputs,
  ...
}: {
  flake.profileModules.gandalr = {
    system = {
      config,
      pkgs,
      ...
    }: {
      sops.secrets."passwords/gandalf/hash" = {
        sopsFile = "${inputs.secrets}/common.yaml";
        neededForUsers = true;
      };

      users.users.gandalf = {
        description = "Gandalf - Global Administrator";
        isNormalUser = true;
        createHome = false;
        extraGroups = ["wheel"];
        shell = pkgs.bash;
        hashedPasswordFile = config.sops.secrets."passwords/gandalf/hash".path;
      };

      security.sudo.extraRules = [
        {
          users = ["gandalf"];
          commands = [
            {
              command = "ALL";
              optons = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
    darwin = {
      config,
      pkgs,
      ...
    }: {
      sops.secrets."passwords/gandalf/plain" = {
        sopsFile = "${inputs.secrets}/common.yaml";
      };

      users.users.gandalf = {
        description = "Gandalf - Global Administrator";
        home = "/var/empty";
        isHidden = true;
        shell = pkgs.bash;
      };

      security.sudo.extraConfig = ''
        gandalf ALL=(ALL) NOPASSWD: ALL
      '';

      system.activationScripts.postActivarion.text = ''
        echo "[Gandalf] Configurando contraseña en macOS a través de dscl..."
        if [ -f "${config.sops.secrets."passwords/gandalf_plain".path}" ]; then
          GANDALF_PASS=$(cat "${config.sops.secrets."passwords/gandalf/plain".path}")
          dscl . -passwd /Users/gandalf "$GANDALF_PASS"
        fi
      '';
    };
  };
}
