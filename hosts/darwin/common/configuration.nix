{ ... }:
{
  system.defaults.dock = {
    enable = true;

    persisten-apps = [
      "/System/Applications/Apps.app"
      "/System/Applications/Mail.app"
      "/System/Applications/Calendar.app"
      "/System/Applications/Safai.app"
      "/System/Applications/Notes.app"
    ];

    persistent-others = [
      {
        title-type = "spacer-title";
      }
    ];
  };

}
