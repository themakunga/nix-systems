{
  flake.rpiModules.disko-sd = {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/mmcblk0";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfar";
              mountpoint = "/boot";
              mounOptions = ["default" "umask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = ["default"];
            };
          };
        };
      };
    };
  };
}
