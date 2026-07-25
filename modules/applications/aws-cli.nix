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
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.aws-cli = mkAppModule "aws-cli" "Enable AWS CLI and cloud profiles" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [
        pkgs.awscli2
      ];
    };
    sysConfig = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.my.cloudProfiles;
      user = config.system.primaryUser or "nicolas";
      isDarwin = pkgs.stdenv.isDarwin;
      userHome =
        if isDarwin
        then "/Users/${user}"
        else "/home/${user}";

      # Generate AWS credentials file content
      awsCredentialsContent = builtins.concatStringsSep "\n" (builtins.map (p: ''
          [${p}]
          aws_access_key_id = ''${config.sops.placeholder."cloud/aws/${p}/access_key_id"}
          aws_secret_access_key = ''${config.sops.placeholder."cloud/aws/${p}/secret_access_key"}
        '')
        cfg.aws);

      # Generate AWS config file content
      awsConfigContent = builtins.concatStringsSep "\n" (builtins.map (p: ''
          [profile ${p}]
          region = ''${config.sops.placeholder."cloud/aws/${p}/region"}
        '')
        cfg.aws);
    in
      lib.mkIf (cfg.aws != []) {
        sops.templates."aws_credentials" = {
          content = awsCredentialsContent;
          owner = user;
        };
        sops.templates."aws_config" = {
          content = awsConfigContent;
          owner = user;
        };

        system.activationScripts =
          if isDarwin
          then {
            postActivation.text = ''
              mkdir -p ${userHome}/.aws
              ln -sf ${config.sops.templates."aws_credentials".path} ${userHome}/.aws/credentials
              ln -sf ${config.sops.templates."aws_config".path} ${userHome}/.aws/config
              chown -R ${user} ${userHome}/.aws
            '';
          }
          else {
            setupAwsConfig = {
              text = ''
                mkdir -p ${userHome}/.aws
                ln -sf ${config.sops.templates."aws_credentials".path} ${userHome}/.aws/credentials
                ln -sf ${config.sops.templates."aws_config".path} ${userHome}/.aws/config
                chown -R ${user} ${userHome}/.aws
              '';
            };
          };
      };
  };
}
