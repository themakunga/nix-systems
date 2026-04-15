{ }:
{
  users.users.users.admin = {
    password = "admin123";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
