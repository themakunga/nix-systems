{
  flake.rpiModules.performance = {
    swapDevices = [
      {
        device = "/swapfile";
        size = 8 * 1024;
        priority = 10;
      }
    ];

    boot.kernel.sysctl = {
      "wm.swappiness" = 10;
      "wm.dirty_writeback_centisecs" = 6000;
    };
  };
}
