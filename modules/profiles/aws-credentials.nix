# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.profileModules.aws-credentials = {
    imports = [self.commonModules.cloud-profiles];
    my.cloudProfiles.aws = map (name: {
      inherit name;
      region = "us-east-1";
      output = "yaml";
    }) ["nicolas" "default" "bbook"];
  };
}
