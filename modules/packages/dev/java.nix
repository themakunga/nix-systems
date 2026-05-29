{
  flake.commonModules.dev-java = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      google-java-format
      gradle
      groovy
      jdk21_headless
      jdt-language-server
      kotlin
      kotlin-language-server
      ktlint
      maven
      spring-boot-cli
    ];
  };
}
