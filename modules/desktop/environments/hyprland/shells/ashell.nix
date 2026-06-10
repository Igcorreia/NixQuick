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
            osConfig.${namespace}.desktop.environments.hyprland.enable == true
            && config.${namespace}.desktop.environments.hyprland.shell == "ashell"
          )
          {
            programs.ashell.enable = true;

            # We have to do this because Home-Manager needs to auto-style it
            services = {
              mako.enable = true;
              elephant.enable = true;
              walker.enable = true;
            };

            # We don't want these to be started by SystemD because it might interfere with other compositors
            # Force Disable SystemD services
            systemd.user.services = {
              mako = lib.mkForce { };
              elephant = lib.mkForce { };
              walker = lib.mkForce { };
            };

            wayland.windowManager.hyprland.settings = {
              exec-once = [
                "uwsm app -- ${lib.getExe pkgs.ashell}"
                "uwsm app -- ${lib.getExe pkgs.mako}"
                "uwsm app -- ${lib.getExe pkgs.elephant}"
                "uwsm app -- ${lib.getExe pkgs.walker} --gapplication-service"
              ];
              bind = [
                "bind = SUPER, R, exec, ${lib.getExe pkgs.walker}"
              ];
            };

            wayland.windowManager.hyprland.extraConfig = ''
              layerrule = blur on, match:namespace ashell-main-layer
              layerrule = ignore_alpha 0, match:namespace ashell-main-layer
            '';
          };
    };
}
