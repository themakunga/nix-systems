# =========================================================
# Archivo de Configuración de NixOS / Home Manager
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

      # Credentials: sensible → sops placeholders
      # Note: use string concatenation to avoid ''${} escaping the interpolation
      awsCredentialsContent = builtins.concatStringsSep "\n" (builtins.map (
          p:
            "[${p.name}]\n"
            + "aws_access_key_id = "
            + config.sops.placeholder."aws/credentials/${p.name}/access_key_id"
            + "\n"
            + "aws_secret_access_key = "
            + config.sops.placeholder."aws/credentials/${p.name}/secret_access_key"
            + "\n"
        )
        cfg.aws);

      # Config: region y output no son sensibles → van directo desde Nix
      awsConfigContent = builtins.concatStringsSep "\n" (builtins.map (p: ''
          [profile ${p.name}]
          region = ${p.region}
          output = ${p.output}
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
