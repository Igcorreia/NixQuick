# System Services Module
{
  flake.modules.nixos.core =
    { ... }:
    {
      # AutoUpgrade
      system.autoUpgrade = {
        enable = true;
        dates = "24:00";
        allowReboot = false;
      };

      # Userland-Related Improvements
      security.rtkit.enable = true;
      security.polkit.enable = true;
      services.dbus.enable = true;
    };
}
