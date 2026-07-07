# Desktop Services Module
{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      # System Dependencies
      networking.networkmanager.enable = true;
      programs = {
        dconf.enable = true;
        uwsm.enable = true;
      };

      environment.systemPackages = with pkgs; [
        brightnessctl
      ];

      services = {
        gvfs.enable = true;
        libinput.enable = true;
        upower.enable = true;
        udisks2.enable = true;

        pipewire = {
          enable = true;
          pulse.enable = true;
          wireplumber = {
            enable = true;
            # Save CPU cycles by skipping camera monitor.
            extraConfig."10-disable-camera" = {
              "wireplumber.profiles".main."monitor.libcamera" = "disabled";
            };
          };
        };
      };
    };
}
