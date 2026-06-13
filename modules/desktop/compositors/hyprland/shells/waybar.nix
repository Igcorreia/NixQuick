{
  flake.modules.homeManager.desktop =
    {
      lib,
      osConfig,
      config,
      namespace,
      pkgs,
      ...
    }:
    {
      config =
        lib.mkIf
          (
            osConfig.${namespace}.desktop.compositors.hyprland.enable == true
            && config.${namespace}.desktop.compositors.hyprland.shell == "waybar"
          )
          {
            # Required Software
            programs = {
              hyprlock.enable = true;
            };
            services = {
              mako.enable = true;
              elephant.enable = true;
              walker = {
                enable = true;
                enableElephantIntegration = true;
              };
            };
            systemd.user.services = { # Allow Home-Manager to manage settings for these services, But Don't Make SystemD Services.
              mako = lib.mkForce {};
              elephant = lib.mkForce {};
              walker = lib.mkForce {};
            };

            # Binds
            wayland.windowManager.hyprland.settings = {
              exec-once = [
                "uwsm app -- ${lib.getExe pkgs.waybar}"
                "uwsm app -- ${lib.getExe pkgs.mako}"
                "uwsm app -- ${lib.getExe pkgs.elephant}"
                "uwsm app -- ${lib.getExe pkgs.walker} --gapplication-service"
              ];

              bind = [
                "SUPER, R, exec, ${lib.getExe pkgs.walker}"
              ];
              layerrule = [
              ];
            };

            programs.waybar = {
              enable = true;
              
            };
          };
    };
}
