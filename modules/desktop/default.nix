# Desktop Main Module
# Contains Options and Essential Services
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      namespace,
      ...
    }:
    {
      options.${namespace} = {
        desktop = {
          enable = lib.mkEnableOption "Desktop Environment Support.";
        };
        greeter = lib.mkOption {
          type = lib.types.enum [
            null
            "greetd"
          ];
          default = null;
          description = "Login Greeter To Enable.";
        };

      };

      config = lib.mkIf config.${namespace}.desktop.enable {
        programs = {
          dconf.enable = true;
          uwsm.enable = true;
        };

        services.gvfs.enable = true;
        services.libinput.enable = true;
        services.upower.enable = true;

        services.pipewire = {
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
