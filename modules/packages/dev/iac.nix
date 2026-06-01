{
  flake.comonModules.dev-iac = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      ansible
      infracost
      opentofu
      pulumi
      safe
      terraform-docs
      terragrunt
      tflint
      trivy
      vault
    ];
  };
}
